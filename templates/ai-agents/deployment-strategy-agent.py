#!/usr/bin/env python3
"""
Deployment Strategy Agent
AI Agent Development Framework v3.7

This AI agent analyzes code changes and deployment history to intelligently
select the optimal deployment strategy (blue-green, canary, or rolling).
"""

import json
import sys
import argparse
import subprocess
import logging
from datetime import datetime, timedelta
from typing import Dict, List, Any, Optional
import numpy as np
from pathlib import Path
import os
import yaml

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class DeploymentStrategyAgent:
    """AI agent for intelligent deployment strategy selection"""
    
    def __init__(self, config_path: Optional[str] = None):
        self.config = self._load_config(config_path)
        self.framework_version = "v3.7"
        self.historical_data_path = self.config.get("historical_data_path", "data/deployment-history.json")
        self.output_path = self.config.get("output_path", "deployment-decision.json")
        
    def _load_config(self, config_path: Optional[str]) -> Dict[str, Any]:
        """Load configuration from file or use defaults"""
        default_config = {
            "risk_thresholds": {
                "low": 3,
                "medium": 8,
                "high": 15
            },
            "strategy_weights": {
                "code_changes": 1.0,
                "infrastructure_changes": 3.0,
                "database_changes": 5.0,
                "dependency_changes": 2.0
            },
            "environment_risk_multiplier": {
                "dev": 0.5,
                "staging": 0.8,
                "prod": 1.5
            },
            "forced_strategies": {
                "database_migration": "blue-green",
                "infrastructure_major": "blue-green",
                "security_patch": "canary"
            }
        }
        
        if config_path and os.path.exists(config_path):
            with open(config_path, 'r') as f:
                config = yaml.safe_load(f)
                # Merge with defaults
                default_config.update(config)
        
        return default_config
    
    def analyze_changes(self, changed_files: List[str]) -> Dict[str, Any]:
        """Analyze code changes to determine deployment risk and strategy"""
        logger.info(f"Analyzing {len(changed_files)} changed files")
        
        analysis = {
            "change_score": 0,
            "risk_factors": [],
            "affected_components": [],
            "change_types": [],
            "file_analysis": []
        }
        
        weights = self.config["strategy_weights"]
        
        # Analyze each file
        for file in changed_files:
            file_analysis = self._analyze_single_file(file)
            analysis["file_analysis"].append(file_analysis)
            
            # Application code changes
            if file.endswith(('.py', '.js', '.go', '.java', '.cpp', '.rs')):
                analysis["change_score"] += weights["code_changes"]
                analysis["affected_components"].append("application")
                analysis["change_types"].append("code")
                
            # Infrastructure changes
            elif file.endswith(('.tf', '.yaml', '.yml')) and any(
                keyword in file.lower() for keyword in ['terraform', 'k8s', 'kubernetes', 'helm']
            ):
                analysis["change_score"] += weights["infrastructure_changes"]
                analysis["affected_components"].append("infrastructure")
                analysis["change_types"].append("infrastructure")
                analysis["risk_factors"].append("infrastructure_change")
                
            # Database changes
            elif file.endswith(('.sql', '.migration')) or 'migration' in file.lower():
                analysis["change_score"] += weights["database_changes"]
                analysis["affected_components"].append("database")
                analysis["change_types"].append("database")
                analysis["risk_factors"].append("database_migration")
                
            # Dependency changes
            elif any(dep_file in file.lower() for dep_file in [
                'requirements', 'package.json', 'go.mod', 'cargo.toml', 'dockerfile'
            ]):
                analysis["change_score"] += weights["dependency_changes"]
                analysis["affected_components"].append("dependencies")
                analysis["change_types"].append("dependencies")
                analysis["risk_factors"].append("dependency_change")
                
            # Configuration changes
            elif file.endswith(('.conf', '.ini', '.env', '.properties')):
                analysis["change_score"] += 1.5
                analysis["affected_components"].append("configuration")
                analysis["change_types"].append("configuration")
                analysis["risk_factors"].append("config_change")
        
        # Analyze change magnitude using git stats
        analysis.update(self._analyze_change_magnitude())
        
        # Deduplicate lists
        analysis["affected_components"] = list(set(analysis["affected_components"]))
        analysis["change_types"] = list(set(analysis["change_types"]))
        analysis["risk_factors"] = list(set(analysis["risk_factors"]))
        
        logger.info(f"Change analysis complete. Risk score: {analysis['change_score']}")
        return analysis
    
    def _analyze_single_file(self, file_path: str) -> Dict[str, Any]:
        """Analyze a single file for specific risk patterns"""
        file_analysis = {
            "file": file_path,
            "risk_indicators": [],
            "complexity_score": 0
        }
        
        try:
            # Analyze git diff for this specific file
            diff_result = subprocess.run([
                "git", "diff", "--stat", "HEAD~1", "--", file_path
            ], capture_output=True, text=True, timeout=10)
            
            if diff_result.stdout:
                # Extract lines changed
                for line in diff_result.stdout.split('\n'):
                    if '|' in line and ('+' in line or '-' in line):
                        parts = line.split('|')
                        if len(parts) > 1:
                            changes_part = parts[1].strip()
                            change_count = changes_part.count('+') + changes_part.count('-')
                            file_analysis["complexity_score"] = change_count
                            
                            # High complexity indicators
                            if change_count > 50:
                                file_analysis["risk_indicators"].append("high_complexity")
                            elif change_count > 20:
                                file_analysis["risk_indicators"].append("medium_complexity")
            
            # Check for critical file patterns
            if any(critical in file_path.lower() for critical in [
                'auth', 'security', 'login', 'permission', 'admin'
            ]):
                file_analysis["risk_indicators"].append("security_related")
            
            if any(critical in file_path.lower() for critical in [
                'payment', 'billing', 'transaction', 'order'
            ]):
                file_analysis["risk_indicators"].append("business_critical")
                
        except Exception as e:
            logger.warning(f"Could not analyze file {file_path}: {e}")
            
        return file_analysis
    
    def _analyze_change_magnitude(self) -> Dict[str, Any]:
        """Analyze the magnitude of changes using git statistics"""
        magnitude_analysis = {
            "lines_added": 0,
            "lines_removed": 0,
            "files_changed": 0,
            "magnitude_multiplier": 1.0
        }
        
        try:
            # Get comprehensive diff statistics
            diff_stats = subprocess.run([
                "git", "diff", "--numstat", "HEAD~1"
            ], capture_output=True, text=True, timeout=15)
            
            if diff_stats.stdout:
                for line in diff_stats.stdout.strip().split('\n'):
                    if line:
                        parts = line.split('\t')
                        if len(parts) >= 2:
                            try:
                                added = int(parts[0]) if parts[0] != '-' else 0
                                removed = int(parts[1]) if parts[1] != '-' else 0
                                magnitude_analysis["lines_added"] += added
                                magnitude_analysis["lines_removed"] += removed
                                magnitude_analysis["files_changed"] += 1
                            except ValueError:
                                continue
                
                # Calculate magnitude multiplier
                total_changes = magnitude_analysis["lines_added"] + magnitude_analysis["lines_removed"]
                if total_changes > 1000:
                    magnitude_analysis["magnitude_multiplier"] = 2.0
                elif total_changes > 500:
                    magnitude_analysis["magnitude_multiplier"] = 1.5
                elif total_changes > 100:
                    magnitude_analysis["magnitude_multiplier"] = 1.2
                    
        except Exception as e:
            logger.warning(f"Could not analyze change magnitude: {e}")
            
        return magnitude_analysis
    
    def predict_deployment_strategy(self, change_analysis: Dict, environment: str, 
                                  historical_data: Optional[List[Dict]] = None) -> Dict[str, Any]:
        """Predict the optimal deployment strategy based on analysis"""
        logger.info(f"Predicting deployment strategy for {environment} environment")
        
        # Load historical data if not provided
        if historical_data is None:
            historical_data = self._load_historical_data()
        
        # Apply environment risk multiplier
        env_multiplier = self.config["environment_risk_multiplier"].get(environment, 1.0)
        adjusted_score = change_analysis["change_score"] * env_multiplier * change_analysis.get("magnitude_multiplier", 1.0)
        
        # Check for forced strategies based on change types
        forced_strategy = self._check_forced_strategies(change_analysis, environment)
        if forced_strategy:
            return self._create_strategy_response(
                forced_strategy, adjusted_score, change_analysis, 
                f"Forced strategy due to {forced_strategy} requirements"
            )
        
        # Determine strategy based on risk score and thresholds
        thresholds = self.config["risk_thresholds"]
        
        if adjusted_score <= thresholds["low"]:
            strategy = "rolling"
            risk_level = "low"
        elif adjusted_score <= thresholds["medium"]:
            strategy = "canary"
            risk_level = "medium"
        else:
            strategy = "blue-green"
            risk_level = "high"
        
        # Environment-specific overrides
        if environment == "prod":
            # Be more conservative in production
            if strategy == "rolling" and adjusted_score > thresholds["low"] * 0.8:
                strategy = "canary"
            if "database_migration" in change_analysis["risk_factors"]:
                strategy = "blue-green"
        elif environment == "dev":
            # Allow more aggressive strategies in development
            if strategy == "blue-green" and adjusted_score < thresholds["high"] * 1.2:
                strategy = "canary"
        
        # Consider historical success rates
        strategy = self._adjust_for_historical_performance(
            strategy, historical_data, environment, change_analysis
        )
        
        return self._create_strategy_response(strategy, adjusted_score, change_analysis)
    
    def _check_forced_strategies(self, change_analysis: Dict, environment: str) -> Optional[str]:
        """Check if any change patterns require a specific strategy"""
        forced_strategies = self.config["forced_strategies"]
        
        for risk_factor in change_analysis["risk_factors"]:
            if risk_factor in forced_strategies:
                return forced_strategies[risk_factor]
        
        # Additional logic for critical combinations
        if (environment == "prod" and 
            "database" in change_analysis["affected_components"] and 
            "infrastructure" in change_analysis["affected_components"]):
            return "blue-green"
        
        return None
    
    def _adjust_for_historical_performance(self, strategy: str, historical_data: List[Dict], 
                                         environment: str, change_analysis: Dict) -> str:
        """Adjust strategy based on historical deployment performance"""
        if not historical_data:
            return strategy
        
        # Filter recent deployments for this environment
        recent_deployments = [
            d for d in historical_data[-20:]  # Last 20 deployments
            if d.get("environment") == environment
        ]
        
        if len(recent_deployments) < 3:
            return strategy  # Not enough data
        
        # Calculate success rates by strategy
        strategy_performance = {}
        for deployment in recent_deployments:
            dep_strategy = deployment.get("strategy", "unknown")
            if dep_strategy not in strategy_performance:
                strategy_performance[dep_strategy] = {"successes": 0, "total": 0}
            
            strategy_performance[dep_strategy]["total"] += 1
            if deployment.get("success", False):
                strategy_performance[dep_strategy]["successes"] += 1
        
        # If current strategy has low success rate, consider alternatives
        if strategy in strategy_performance:
            success_rate = (strategy_performance[strategy]["successes"] / 
                          strategy_performance[strategy]["total"])
            
            if success_rate < 0.7:  # Less than 70% success rate
                # Find better performing strategy
                best_strategy = strategy
                best_rate = success_rate
                
                for strat, perf in strategy_performance.items():
                    if perf["total"] >= 2:  # Minimum sample size
                        rate = perf["successes"] / perf["total"]
                        if rate > best_rate:
                            best_strategy = strat
                            best_rate = rate
                
                logger.info(f"Adjusting strategy from {strategy} to {best_strategy} based on historical performance")
                return best_strategy
        
        return strategy
    
    def _create_strategy_response(self, strategy: str, risk_score: float, 
                                change_analysis: Dict, custom_reasoning: str = None) -> Dict[str, Any]:
        """Create a comprehensive strategy response"""
        
        # Determine risk level
        thresholds = self.config["risk_thresholds"]
        if risk_score <= thresholds["low"]:
            risk_level = "low"
        elif risk_score <= thresholds["medium"]:
            risk_level = "medium"
        else:
            risk_level = "high"
        
        # Generate reasoning
        reasoning = custom_reasoning or self._generate_reasoning(change_analysis, strategy, risk_level)
        
        # Generate recommendations
        recommendations = self._generate_recommendations(change_analysis, strategy, risk_level)
        
        # Calculate confidence based on various factors
        confidence = self._calculate_confidence(change_analysis, strategy, risk_score)
        
        return {
            "strategy": strategy,
            "risk_level": risk_level,
            "risk_score": risk_score,
            "confidence": confidence,
            "reasoning": reasoning,
            "recommendations": recommendations,
            "change_analysis": change_analysis,
            "framework_version": self.framework_version,
            "timestamp": datetime.now().isoformat(),
            "decision_factors": {
                "affected_components": change_analysis["affected_components"],
                "risk_factors": change_analysis["risk_factors"],
                "change_types": change_analysis["change_types"],
                "files_changed": len(change_analysis.get("file_analysis", [])),
                "lines_changed": (change_analysis.get("lines_added", 0) + 
                                change_analysis.get("lines_removed", 0))
            }
        }
    
    def _generate_reasoning(self, change_analysis: Dict, strategy: str, risk_level: str) -> str:
        """Generate human-readable reasoning for the strategy decision"""
        
        reasoning_parts = []
        
        # Risk level explanation
        reasoning_parts.append(f"Risk level assessed as {risk_level} based on change analysis.")
        
        # Component impact
        if change_analysis["affected_components"]:
            components = ", ".join(change_analysis["affected_components"])
            reasoning_parts.append(f"Changes affect: {components}.")
        
        # Strategy justification
        strategy_justifications = {
            "rolling": "Rolling deployment selected for minimal risk changes with gradual rollout.",
            "canary": "Canary deployment selected to validate changes with limited user exposure.",
            "blue-green": "Blue-green deployment selected for high-risk changes requiring instant rollback capability."
        }
        
        reasoning_parts.append(strategy_justifications.get(strategy, f"{strategy} deployment selected."))
        
        # Risk factors
        if change_analysis["risk_factors"]:
            factors = ", ".join(change_analysis["risk_factors"])
            reasoning_parts.append(f"Key risk factors identified: {factors}.")
        
        return " ".join(reasoning_parts)
    
    def _generate_recommendations(self, change_analysis: Dict, strategy: str, risk_level: str) -> List[str]:
        """Generate specific recommendations based on the deployment strategy"""
        
        recommendations = []
        
        # General recommendations based on strategy
        if strategy == "blue-green":
            recommendations.extend([
                "Ensure health checks are comprehensive and reliable",
                "Prepare rollback procedures and validate rollback capability",
                "Monitor application metrics closely during traffic switch",
                "Consider database migration strategy if schema changes are involved"
            ])
        elif strategy == "canary":
            recommendations.extend([
                "Start with 10% traffic to canary deployment",
                "Monitor error rates, latency, and business metrics",
                "Gradually increase traffic based on success criteria",
                "Set up automated rollback triggers for anomaly detection"
            ])
        elif strategy == "rolling":
            recommendations.extend([
                "Ensure proper health checks and readiness probes",
                "Validate backward compatibility of changes",
                "Monitor individual instance health during rollout",
                "Plan for quick rollback if issues are detected"
            ])
        
        # Specific recommendations based on change types
        if "database" in change_analysis["affected_components"]:
            recommendations.append("Test database migrations thoroughly in staging environment")
            recommendations.append("Ensure database changes are backward compatible")
        
        if "infrastructure" in change_analysis["affected_components"]:
            recommendations.append("Validate infrastructure changes in non-production environments")
            recommendations.append("Ensure monitoring and alerting covers infrastructure changes")
        
        if "security_related" in [item for sublist in [fa.get("risk_indicators", []) for fa in change_analysis.get("file_analysis", [])] for item in sublist]:
            recommendations.append("Conduct security review and penetration testing")
            recommendations.append("Verify authentication and authorization systems")
        
        # Framework-specific recommendations
        recommendations.append("Update AI context with deployment results for continuous learning")
        recommendations.append("Document any manual intervention points for future automation")
        
        return recommendations
    
    def _calculate_confidence(self, change_analysis: Dict, strategy: str, risk_score: float) -> float:
        """Calculate confidence score for the strategy decision"""
        
        confidence_factors = []
        
        # Base confidence based on clear risk categorization
        thresholds = self.config["risk_thresholds"]
        if risk_score <= thresholds["low"] or risk_score >= thresholds["high"]:
            confidence_factors.append(0.9)  # Clear low or high risk
        else:
            confidence_factors.append(0.7)  # Medium risk, less certain
        
        # Confidence based on number of risk factors
        risk_factor_count = len(change_analysis["risk_factors"])
        if risk_factor_count == 0:
            confidence_factors.append(0.9)
        elif risk_factor_count <= 2:
            confidence_factors.append(0.8)
        else:
            confidence_factors.append(0.6)
        
        # Confidence based on change complexity
        if change_analysis.get("magnitude_multiplier", 1.0) == 1.0:
            confidence_factors.append(0.85)  # Normal change size
        else:
            confidence_factors.append(0.7)   # Large change, more uncertainty
        
        # Average confidence factors
        return sum(confidence_factors) / len(confidence_factors)
    
    def _load_historical_data(self) -> List[Dict]:
        """Load historical deployment data"""
        try:
            if os.path.exists(self.historical_data_path):
                with open(self.historical_data_path, 'r') as f:
                    return json.load(f)
        except Exception as e:
            logger.warning(f"Could not load historical data: {e}")
        
        return []
    
    def save_decision(self, decision: Dict[str, Any]) -> None:
        """Save the deployment decision to file"""
        try:
            # Ensure output directory exists
            os.makedirs(os.path.dirname(self.output_path), exist_ok=True)
            
            with open(self.output_path, 'w') as f:
                json.dump(decision, f, indent=2)
            
            logger.info(f"Decision saved to {self.output_path}")
            
        except Exception as e:
            logger.error(f"Could not save decision: {e}")
            raise


def main():
    """Main entry point for the deployment strategy agent"""
    parser = argparse.ArgumentParser(description="AI Deployment Strategy Agent")
    parser.add_argument("--analyze-changes", required=True, help="Comma-separated list of changed files")
    parser.add_argument("--environment", required=True, choices=["dev", "staging", "prod"], 
                       help="Target deployment environment")
    parser.add_argument("--historical-data", help="Path to historical deployment data JSON file")
    parser.add_argument("--output-decision", help="Path to save deployment decision JSON")
    parser.add_argument("--config", help="Path to agent configuration YAML file")
    parser.add_argument("--framework-version", default="v3.7", help="Framework version")
    parser.add_argument("--verbose", "-v", action="store_true", help="Enable verbose logging")
    
    args = parser.parse_args()
    
    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)
    
    try:
        # Initialize agent
        agent = DeploymentStrategyAgent(config_path=args.config)
        if args.historical_data:
            agent.historical_data_path = args.historical_data
        if args.output_decision:
            agent.output_path = args.output_decision
        
        # Parse changed files
        changed_files = [f.strip() for f in args.analyze_changes.split(',') if f.strip()]
        
        # Analyze changes
        change_analysis = agent.analyze_changes(changed_files)
        
        # Predict strategy
        decision = agent.predict_deployment_strategy(change_analysis, args.environment)
        
        # Save decision
        agent.save_decision(decision)
        
        # Print summary
        print(f"🤖 AI Deployment Strategy Decision:")
        print(f"   Strategy: {decision['strategy']}")
        print(f"   Risk Level: {decision['risk_level']}")
        print(f"   Confidence: {decision['confidence']:.2f}")
        print(f"   Reasoning: {decision['reasoning']}")
        
        if decision['recommendations']:
            print(f"   Recommendations:")
            for rec in decision['recommendations']:
                print(f"   - {rec}")
        
        return 0
        
    except Exception as e:
        logger.error(f"Agent execution failed: {e}")
        return 1


if __name__ == "__main__":
    sys.exit(main())