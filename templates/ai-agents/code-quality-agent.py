#!/usr/bin/env python3
"""
Code Quality Agent
AI Agent Development Framework v3.7

This AI agent analyzes code quality, identifies issues, and provides
intelligent recommendations for improvement following framework standards.
"""

import json
import sys
import argparse
import subprocess
import logging
import os
import ast
import re
from typing import Dict, List, Any, Optional, Union
from pathlib import Path
from datetime import datetime
import yaml

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class CodeQualityAgent:
    """AI agent for comprehensive code quality analysis"""
    
    def __init__(self, config_path: Optional[str] = None):
        self.config = self._load_config(config_path)
        self.framework_version = "v3.7"
        self.output_path = self.config.get("output_path", "ai-analysis-results.json")
        self.quality_standards = self._load_quality_standards()
        
    def _load_config(self, config_path: Optional[str]) -> Dict[str, Any]:
        """Load configuration from file or use defaults"""
        default_config = {
            "quality_thresholds": {
                "complexity_threshold": 10,
                "line_length_threshold": 100,
                "function_length_threshold": 50,
                "class_length_threshold": 200,
                "duplicate_threshold": 6
            },
            "weight_factors": {
                "complexity": 0.3,
                "maintainability": 0.25,
                "security": 0.2,
                "performance": 0.15,
                "style": 0.1
            },
            "security_patterns": {
                "sql_injection": [r"execute\(.*%.*\)", r"query\(.*\+.*\)"],
                "hardcoded_secrets": [r"password\s*=\s*['\"][^'\"]+['\"]", r"api_key\s*=\s*['\"][^'\"]+['\"]"],
                "weak_crypto": [r"md5\(", r"sha1\(", r"DES\("],
                "xss_vulnerability": [r"innerHTML\s*=", r"document\.write\("]
            },
            "performance_patterns": {
                "inefficient_loops": [r"for.*in.*len\(", r"while.*len\(.*\)"],
                "n_plus_one": [r"for.*\.get\(", r"for.*\.filter\("],
                "large_data_structures": [r"list\(\[.*\]\*\d{4,}", r"dict\(\{.*\}\*\d{4,}"]
            }
        }
        
        if config_path and os.path.exists(config_path):
            with open(config_path, 'r') as f:
                config = yaml.safe_load(f)
                default_config.update(config)
        
        return default_config
    
    def _load_quality_standards(self) -> Dict[str, Any]:
        """Load Framework v3.7 quality standards"""
        return {
            "framework_compliance": {
                "required_docstrings": True,
                "type_annotations": True,
                "error_handling": True,
                "logging_usage": True,
                "test_coverage": 95.0
            },
            "ai_integration": {
                "ai_agent_patterns": True,
                "context_management": True,
                "decision_logging": True,
                "human_oversight_points": True
            },
            "security_by_design": {
                "input_validation": True,
                "output_sanitization": True,
                "authentication_checks": True,
                "authorization_validation": True,
                "audit_logging": True
            }
        }
    
    def analyze_files(self, file_paths: List[str], project_context: str = "") -> Dict[str, Any]:
        """Analyze multiple files for code quality"""
        logger.info(f"Analyzing {len(file_paths)} files for code quality")
        
        analysis_results = {
            "overall_score": 0,
            "framework_compliance": {},
            "security_rating": "unknown",
            "findings": [],
            "recommendations": [],
            "file_analyses": {},
            "summary": {},
            "timestamp": datetime.now().isoformat(),
            "framework_version": self.framework_version
        }
        
        total_score = 0
        total_files = 0
        
        # Analyze each file
        for file_path in file_paths:
            if os.path.exists(file_path):
                file_analysis = self._analyze_single_file(file_path)
                analysis_results["file_analyses"][file_path] = file_analysis
                
                if file_analysis["quality_score"] > 0:
                    total_score += file_analysis["quality_score"]
                    total_files += 1
                    
                # Collect findings and recommendations
                analysis_results["findings"].extend(file_analysis["findings"])
                analysis_results["recommendations"].extend(file_analysis["recommendations"])
        
        # Calculate overall metrics
        if total_files > 0:
            analysis_results["overall_score"] = min(100, total_score / total_files)
        
        analysis_results["security_rating"] = self._calculate_security_rating(analysis_results)
        analysis_results["framework_compliance"] = self._assess_framework_compliance(analysis_results)
        analysis_results["summary"] = self._generate_summary(analysis_results)
        
        # Add AI-powered insights
        analysis_results["ai_insights"] = self._generate_ai_insights(analysis_results, project_context)
        
        return analysis_results
    
    def _analyze_single_file(self, file_path: str) -> Dict[str, Any]:
        """Analyze a single file comprehensively"""
        logger.debug(f"Analyzing file: {file_path}")
        
        file_analysis = {
            "file_path": file_path,
            "quality_score": 0,
            "findings": [],
            "recommendations": [],
            "metrics": {},
            "security_issues": [],
            "performance_issues": [],
            "style_issues": [],
            "complexity_metrics": {}
        }
        
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
                
            # Determine file type and run appropriate analysis
            file_extension = Path(file_path).suffix.lower()
            
            if file_extension == '.py':
                file_analysis.update(self._analyze_python_file(file_path, content))
            elif file_extension in ['.js', '.ts']:
                file_analysis.update(self._analyze_javascript_file(file_path, content))
            elif file_extension in ['.go']:
                file_analysis.update(self._analyze_go_file(file_path, content))
            else:
                file_analysis.update(self._analyze_generic_file(file_path, content))
                
            # Common analyses for all file types
            file_analysis["security_issues"].extend(self._check_security_patterns(content))
            file_analysis["performance_issues"].extend(self._check_performance_patterns(content))
            file_analysis["style_issues"].extend(self._check_style_issues(content, file_path))
            
            # Calculate overall file score
            file_analysis["quality_score"] = self._calculate_file_score(file_analysis)
            
        except Exception as e:
            logger.error(f"Error analyzing file {file_path}: {e}")
            file_analysis["findings"].append({
                "type": "error",
                "severity": "high",
                "message": f"Failed to analyze file: {e}",
                "line": 0
            })
        
        return file_analysis
    
    def _analyze_python_file(self, file_path: str, content: str) -> Dict[str, Any]:
        """Analyze Python file using AST and static analysis"""
        analysis = {
            "findings": [],
            "recommendations": [],
            "metrics": {},
            "complexity_metrics": {}
        }
        
        try:
            # Parse AST
            tree = ast.parse(content)
            
            # Analyze AST
            analysis.update(self._analyze_python_ast(tree, content))
            
            # Check for framework compliance
            analysis["findings"].extend(self._check_python_framework_compliance(tree, content))
            
            # Run external tools if available
            analysis.update(self._run_python_external_tools(file_path))
            
        except SyntaxError as e:
            analysis["findings"].append({
                "type": "syntax_error",
                "severity": "critical",
                "message": f"Syntax error: {e.msg}",
                "line": e.lineno or 0,
                "column": e.offset or 0
            })
        
        return analysis
    
    def _analyze_python_ast(self, tree: ast.AST, content: str) -> Dict[str, Any]:
        """Analyze Python AST for quality metrics"""
        analysis = {
            "findings": [],
            "recommendations": [],
            "metrics": {
                "functions": 0,
                "classes": 0,
                "lines_of_code": len(content.split('\n')),
                "complexity": 0
            },
            "complexity_metrics": {}
        }
        
        for node in ast.walk(tree):
            # Count functions and classes
            if isinstance(node, ast.FunctionDef):
                analysis["metrics"]["functions"] += 1
                func_analysis = self._analyze_function_complexity(node)
                analysis["complexity_metrics"][f"function_{node.name}"] = func_analysis
                
                # Check function length
                func_length = node.end_lineno - node.lineno if hasattr(node, 'end_lineno') else 0
                if func_length > self.config["quality_thresholds"]["function_length_threshold"]:
                    analysis["findings"].append({
                        "type": "function_too_long",
                        "severity": "medium",
                        "message": f"Function '{node.name}' is too long ({func_length} lines)",
                        "line": node.lineno,
                        "suggestion": "Consider breaking this function into smaller functions"
                    })
                
                # Check for docstring
                if not ast.get_docstring(node):
                    analysis["findings"].append({
                        "type": "missing_docstring",
                        "severity": "low",
                        "message": f"Function '{node.name}' missing docstring",
                        "line": node.lineno,
                        "suggestion": "Add docstring to document function purpose and parameters"
                    })
            
            elif isinstance(node, ast.ClassDef):
                analysis["metrics"]["classes"] += 1
                
                # Check class length
                class_length = node.end_lineno - node.lineno if hasattr(node, 'end_lineno') else 0
                if class_length > self.config["quality_thresholds"]["class_length_threshold"]:
                    analysis["findings"].append({
                        "type": "class_too_long",
                        "severity": "medium",
                        "message": f"Class '{node.name}' is too long ({class_length} lines)",
                        "line": node.lineno,
                        "suggestion": "Consider using composition or breaking into smaller classes"
                    })
                
                # Check for docstring
                if not ast.get_docstring(node):
                    analysis["findings"].append({
                        "type": "missing_docstring",
                        "severity": "low",
                        "message": f"Class '{node.name}' missing docstring",
                        "line": node.lineno,
                        "suggestion": "Add docstring to document class purpose and usage"
                    })
        
        return analysis
    
    def _analyze_function_complexity(self, func_node: ast.FunctionDef) -> Dict[str, Any]:
        """Calculate cyclomatic complexity for a function"""
        complexity = 1  # Base complexity
        
        for node in ast.walk(func_node):
            if isinstance(node, (ast.If, ast.While, ast.For, ast.AsyncFor)):
                complexity += 1
            elif isinstance(node, ast.ExceptHandler):
                complexity += 1
            elif isinstance(node, ast.BoolOp):
                complexity += len(node.values) - 1
        
        return {
            "cyclomatic_complexity": complexity,
            "name": func_node.name,
            "line": func_node.lineno,
            "parameters": len(func_node.args.args),
            "is_complex": complexity > self.config["quality_thresholds"]["complexity_threshold"]
        }
    
    def _check_python_framework_compliance(self, tree: ast.AST, content: str) -> List[Dict[str, Any]]:
        """Check Python code for Framework v3.7 compliance"""
        compliance_issues = []
        
        # Check for logging usage
        has_logging = 'import logging' in content or 'from logging' in content
        if not has_logging:
            compliance_issues.append({
                "type": "framework_compliance",
                "severity": "medium",
                "message": "No logging usage detected - Framework v3.7 requires comprehensive logging",
                "line": 1,
                "suggestion": "Add logging import and use logger for important events"
            })
        
        # Check for error handling patterns
        has_error_handling = any(isinstance(node, ast.Try) for node in ast.walk(tree))
        if not has_error_handling and any(isinstance(node, ast.FunctionDef) for node in ast.walk(tree)):
            compliance_issues.append({
                "type": "framework_compliance",
                "severity": "medium",
                "message": "No error handling detected - Framework v3.7 requires robust error handling",
                "line": 1,
                "suggestion": "Add try-except blocks for potential failure points"
            })
        
        # Check for type annotations (Python 3.5+)
        functions_without_annotations = []
        for node in ast.walk(tree):
            if isinstance(node, ast.FunctionDef):
                if not node.returns and not any(arg.annotation for arg in node.args.args):
                    functions_without_annotations.append(node.name)
        
        if functions_without_annotations:
            compliance_issues.append({
                "type": "framework_compliance",
                "severity": "low",
                "message": f"Functions without type annotations: {', '.join(functions_without_annotations)}",
                "line": 1,
                "suggestion": "Add type annotations for better code clarity and IDE support"
            })
        
        return compliance_issues
    
    def _run_python_external_tools(self, file_path: str) -> Dict[str, Any]:
        """Run external Python quality tools if available"""
        analysis = {
            "external_tool_results": {},
            "findings": [],
            "recommendations": []
        }
        
        # Try to run flake8 for style checking
        try:
            result = subprocess.run([
                'flake8', '--select=E,W,F', '--format=json', file_path
            ], capture_output=True, text=True, timeout=30)
            
            if result.returncode == 0 or result.stdout:
                analysis["external_tool_results"]["flake8"] = result.stdout
                # Parse flake8 results if needed
                
        except (subprocess.TimeoutExpired, FileNotFoundError):
            logger.debug("flake8 not available or timed out")
        
        # Try to run mypy for type checking
        try:
            result = subprocess.run([
                'mypy', '--show-error-codes', '--json-report', '/tmp/mypy_report', file_path
            ], capture_output=True, text=True, timeout=30)
            
            if result.returncode == 0 or result.stderr:
                analysis["external_tool_results"]["mypy"] = result.stderr
                
        except (subprocess.TimeoutExpired, FileNotFoundError):
            logger.debug("mypy not available or timed out")
        
        return analysis
    
    def _analyze_javascript_file(self, file_path: str, content: str) -> Dict[str, Any]:
        """Analyze JavaScript/TypeScript file"""
        analysis = {
            "findings": [],
            "recommendations": [],
            "metrics": {
                "functions": len(re.findall(r'function\s+\w+|const\s+\w+\s*=\s*\(.*\)\s*=>', content)),
                "classes": len(re.findall(r'class\s+\w+', content)),
                "lines_of_code": len(content.split('\n'))
            }
        }
        
        # Check for console.log statements (should use proper logging)
        console_logs = re.finditer(r'console\.log', content)
        for match in console_logs:
            line_num = content[:match.start()].count('\n') + 1
            analysis["findings"].append({
                "type": "improper_logging",
                "severity": "low",
                "message": "Using console.log instead of proper logging framework",
                "line": line_num,
                "suggestion": "Use a proper logging framework instead of console.log"
            })
        
        # Check for var usage (prefer let/const)
        var_usage = re.finditer(r'\bvar\s+', content)
        for match in var_usage:
            line_num = content[:match.start()].count('\n') + 1
            analysis["findings"].append({
                "type": "outdated_syntax",
                "severity": "low",
                "message": "Using 'var' declaration (prefer 'let' or 'const')",
                "line": line_num,
                "suggestion": "Use 'let' or 'const' instead of 'var' for better scope management"
            })
        
        return analysis
    
    def _analyze_go_file(self, file_path: str, content: str) -> Dict[str, Any]:
        """Analyze Go file"""
        analysis = {
            "findings": [],
            "recommendations": [],
            "metrics": {
                "functions": len(re.findall(r'func\s+\w+', content)),
                "structs": len(re.findall(r'type\s+\w+\s+struct', content)),
                "lines_of_code": len(content.split('\n'))
            }
        }
        
        # Check for proper error handling
        error_checks = len(re.findall(r'if\s+err\s*!=\s*nil', content))
        function_count = analysis["metrics"]["functions"]
        
        if function_count > 0 and error_checks == 0:
            analysis["findings"].append({
                "type": "missing_error_handling",
                "severity": "high",
                "message": "No error handling detected in Go file",
                "line": 1,
                "suggestion": "Add proper error handling with 'if err != nil' checks"
            })
        
        return analysis
    
    def _analyze_generic_file(self, file_path: str, content: str) -> Dict[str, Any]:
        """Analyze generic file for common issues"""
        analysis = {
            "findings": [],
            "recommendations": [],
            "metrics": {
                "lines_of_code": len(content.split('\n')),
                "file_size": len(content)
            }
        }
        
        # Check file size
        if len(content) > 10000:  # 10KB
            analysis["findings"].append({
                "type": "large_file",
                "severity": "medium",
                "message": f"Large file size ({len(content)} bytes)",
                "line": 1,
                "suggestion": "Consider breaking large files into smaller modules"
            })
        
        return analysis
    
    def _check_security_patterns(self, content: str) -> List[Dict[str, Any]]:
        """Check for security vulnerability patterns"""
        security_issues = []
        
        for vulnerability_type, patterns in self.config["security_patterns"].items():
            for pattern in patterns:
                matches = re.finditer(pattern, content, re.IGNORECASE)
                for match in matches:
                    line_num = content[:match.start()].count('\n') + 1
                    security_issues.append({
                        "type": "security_vulnerability",
                        "vulnerability_type": vulnerability_type,
                        "severity": "high",
                        "message": f"Potential {vulnerability_type.replace('_', ' ')} vulnerability detected",
                        "line": line_num,
                        "pattern": pattern,
                        "suggestion": self._get_security_suggestion(vulnerability_type)
                    })
        
        return security_issues
    
    def _check_performance_patterns(self, content: str) -> List[Dict[str, Any]]:
        """Check for performance anti-patterns"""
        performance_issues = []
        
        for issue_type, patterns in self.config["performance_patterns"].items():
            for pattern in patterns:
                matches = re.finditer(pattern, content, re.IGNORECASE)
                for match in matches:
                    line_num = content[:match.start()].count('\n') + 1
                    performance_issues.append({
                        "type": "performance_issue",
                        "issue_type": issue_type,
                        "severity": "medium",
                        "message": f"Potential {issue_type.replace('_', ' ')} detected",
                        "line": line_num,
                        "pattern": pattern,
                        "suggestion": self._get_performance_suggestion(issue_type)
                    })
        
        return performance_issues
    
    def _check_style_issues(self, content: str, file_path: str) -> List[Dict[str, Any]]:
        """Check for code style issues"""
        style_issues = []
        
        lines = content.split('\n')
        for line_num, line in enumerate(lines, 1):
            # Check line length
            if len(line) > self.config["quality_thresholds"]["line_length_threshold"]:
                style_issues.append({
                    "type": "style_issue",
                    "style_type": "line_too_long",
                    "severity": "low",
                    "message": f"Line too long ({len(line)} characters)",
                    "line": line_num,
                    "suggestion": "Break long lines for better readability"
                })
            
            # Check for trailing whitespace
            if line.rstrip() != line:
                style_issues.append({
                    "type": "style_issue",
                    "style_type": "trailing_whitespace",
                    "severity": "low",
                    "message": "Trailing whitespace detected",
                    "line": line_num,
                    "suggestion": "Remove trailing whitespace"
                })
        
        return style_issues
    
    def _get_security_suggestion(self, vulnerability_type: str) -> str:
        """Get security remediation suggestions"""
        suggestions = {
            "sql_injection": "Use parameterized queries or prepared statements",
            "hardcoded_secrets": "Use environment variables or secure secret management",
            "weak_crypto": "Use strong cryptographic algorithms like SHA-256 or AES",
            "xss_vulnerability": "Sanitize user input and use safe DOM manipulation methods"
        }
        return suggestions.get(vulnerability_type, "Review code for security best practices")
    
    def _get_performance_suggestion(self, issue_type: str) -> str:
        """Get performance optimization suggestions"""
        suggestions = {
            "inefficient_loops": "Use list comprehensions or built-in functions like enumerate()",
            "n_plus_one": "Consider using bulk operations or prefetch related data",
            "large_data_structures": "Use generators or process data in chunks"
        }
        return suggestions.get(issue_type, "Optimize algorithm for better performance")
    
    def _calculate_file_score(self, file_analysis: Dict[str, Any]) -> float:
        """Calculate overall quality score for a file"""
        base_score = 100.0
        
        # Deduct points for issues
        for finding in file_analysis["findings"]:
            severity = finding.get("severity", "low")
            if severity == "critical":
                base_score -= 20
            elif severity == "high":
                base_score -= 10
            elif severity == "medium":
                base_score -= 5
            elif severity == "low":
                base_score -= 1
        
        # Deduct points for security issues
        for issue in file_analysis["security_issues"]:
            base_score -= 15  # Security issues are serious
        
        # Deduct points for performance issues
        for issue in file_analysis["performance_issues"]:
            base_score -= 5
        
        # Deduct points for style issues
        for issue in file_analysis["style_issues"]:
            base_score -= 1
        
        return max(0, base_score)
    
    def _calculate_security_rating(self, analysis_results: Dict[str, Any]) -> str:
        """Calculate overall security rating"""
        total_security_issues = 0
        critical_security_issues = 0
        
        for file_analysis in analysis_results["file_analyses"].values():
            security_issues = file_analysis.get("security_issues", [])
            total_security_issues += len(security_issues)
            
            for issue in security_issues:
                if issue.get("severity") in ["critical", "high"]:
                    critical_security_issues += 1
        
        if critical_security_issues > 0:
            return "critical"
        elif total_security_issues > 5:
            return "high"
        elif total_security_issues > 0:
            return "medium"
        else:
            return "low"
    
    def _assess_framework_compliance(self, analysis_results: Dict[str, Any]) -> Dict[str, Any]:
        """Assess compliance with Framework v3.7 standards"""
        compliance = {
            "overall_score": 0,
            "categories": {},
            "violations": []
        }
        
        # Count framework compliance issues
        framework_issues = []
        for file_analysis in analysis_results["file_analyses"].values():
            for finding in file_analysis.get("findings", []):
                if finding.get("type") == "framework_compliance":
                    framework_issues.append(finding)
        
        # Calculate compliance score
        total_files = len(analysis_results["file_analyses"])
        if total_files > 0:
            compliance_violations = len(framework_issues)
            compliance["overall_score"] = max(0, 100 - (compliance_violations * 10))
        
        compliance["violations"] = framework_issues
        return compliance
    
    def _generate_summary(self, analysis_results: Dict[str, Any]) -> Dict[str, Any]:
        """Generate analysis summary"""
        total_findings = len(analysis_results["findings"])
        total_files = len(analysis_results["file_analyses"])
        
        summary = {
            "total_files_analyzed": total_files,
            "total_findings": total_findings,
            "average_quality_score": analysis_results["overall_score"],
            "security_rating": analysis_results["security_rating"],
            "framework_compliance_score": analysis_results["framework_compliance"]["overall_score"],
            "findings_by_severity": {
                "critical": len([f for f in analysis_results["findings"] if f.get("severity") == "critical"]),
                "high": len([f for f in analysis_results["findings"] if f.get("severity") == "high"]),
                "medium": len([f for f in analysis_results["findings"] if f.get("severity") == "medium"]),
                "low": len([f for f in analysis_results["findings"] if f.get("severity") == "low"])
            }
        }
        
        return summary
    
    def _generate_ai_insights(self, analysis_results: Dict[str, Any], project_context: str) -> Dict[str, Any]:
        """Generate AI-powered insights and recommendations"""
        insights = {
            "code_patterns": [],
            "improvement_priorities": [],
            "architectural_suggestions": [],
            "maintenance_recommendations": []
        }
        
        # Analyze patterns in findings
        findings_by_type = {}
        for finding in analysis_results["findings"]:
            finding_type = finding.get("type", "unknown")
            if finding_type not in findings_by_type:
                findings_by_type[finding_type] = []
            findings_by_type[finding_type].append(finding)
        
        # Generate insights based on patterns
        for finding_type, findings in findings_by_type.items():
            if len(findings) > 2:  # Pattern threshold
                insights["code_patterns"].append({
                    "pattern": finding_type,
                    "frequency": len(findings),
                    "recommendation": f"Consider addressing {finding_type} systematically across the codebase"
                })
        
        # Prioritize improvements based on severity and frequency
        severity_weights = {"critical": 4, "high": 3, "medium": 2, "low": 1}
        improvement_priorities = []
        
        for finding_type, findings in findings_by_type.items():
            weight = sum(severity_weights.get(f.get("severity", "low"), 1) for f in findings)
            improvement_priorities.append({
                "issue_type": finding_type,
                "priority_score": weight,
                "count": len(findings)
            })
        
        improvement_priorities.sort(key=lambda x: x["priority_score"], reverse=True)
        insights["improvement_priorities"] = improvement_priorities[:5]  # Top 5
        
        # Generate maintenance recommendations
        if analysis_results["overall_score"] < 70:
            insights["maintenance_recommendations"].append("Schedule code refactoring sprint to address quality issues")
        
        if analysis_results["security_rating"] in ["critical", "high"]:
            insights["maintenance_recommendations"].append("Immediate security review and remediation required")
        
        if analysis_results["framework_compliance"]["overall_score"] < 80:
            insights["maintenance_recommendations"].append("Update code to meet Framework v3.7 standards")
        
        return insights
    
    def save_results(self, analysis_results: Dict[str, Any]) -> None:
        """Save analysis results to file"""
        try:
            # Ensure output directory exists
            os.makedirs(os.path.dirname(self.output_path), exist_ok=True)
            
            with open(self.output_path, 'w') as f:
                json.dump(analysis_results, f, indent=2)
            
            logger.info(f"Analysis results saved to {self.output_path}")
            
        except Exception as e:
            logger.error(f"Could not save results: {e}")
            raise


def main():
    """Main entry point for the code quality agent"""
    parser = argparse.ArgumentParser(description="AI Code Quality Agent")
    parser.add_argument("--changed-files", help="Comma-separated list of files to analyze")
    parser.add_argument("--analyze-all", action="store_true", help="Analyze all source files in project")
    parser.add_argument("--project-context", help="Project context for AI analysis")
    parser.add_argument("--output-format", choices=["json", "github-annotations"], default="json",
                       help="Output format for results")
    parser.add_argument("--config", help="Path to agent configuration YAML file")
    parser.add_argument("--output", help="Path to save analysis results")
    parser.add_argument("--verbose", "-v", action="store_true", help="Enable verbose logging")
    
    args = parser.parse_args()
    
    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)
    
    try:
        # Initialize agent
        agent = CodeQualityAgent(config_path=args.config)
        if args.output:
            agent.output_path = args.output
        
        # Determine files to analyze
        files_to_analyze = []
        
        if args.changed_files:
            files_to_analyze = [f.strip() for f in args.changed_files.split(',') if f.strip()]
        elif args.analyze_all:
            # Find all source files
            source_extensions = ['.py', '.js', '.ts', '.go', '.java', '.cpp', '.rs']
            for ext in source_extensions:
                try:
                    result = subprocess.run([
                        'find', '.', '-name', f'*{ext}', '-type', 'f'
                    ], capture_output=True, text=True, timeout=30)
                    
                    if result.stdout:
                        files_to_analyze.extend(result.stdout.strip().split('\n'))
                except subprocess.TimeoutExpired:
                    logger.warning(f"Timeout finding {ext} files")
        else:
            logger.error("Must specify either --changed-files or --analyze-all")
            return 1
        
        if not files_to_analyze:
            logger.warning("No files to analyze")
            return 0
        
        # Analyze files
        project_context = args.project_context or "AI Agent Development Framework v3.7 project"
        analysis_results = agent.analyze_files(files_to_analyze, project_context)
        
        # Save results
        agent.save_results(analysis_results)
        
        # Output results based on format
        if args.output_format == "github-annotations":
            # Output GitHub Actions annotations format
            for finding in analysis_results["findings"]:
                severity_map = {"critical": "error", "high": "error", "medium": "warning", "low": "notice"}
                annotation_type = severity_map.get(finding.get("severity", "low"), "notice")
                
                file_path = finding.get("file_path", "unknown")
                line = finding.get("line", 1)
                message = finding.get("message", "Code quality issue")
                
                print(f"::{annotation_type} file={file_path},line={line}::{message}")
        else:
            # Standard JSON output summary
            print(f"🤖 Code Quality Analysis Complete:")
            print(f"   Overall Score: {analysis_results['overall_score']:.1f}/100")
            print(f"   Security Rating: {analysis_results['security_rating']}")
            print(f"   Framework Compliance: {analysis_results['framework_compliance']['overall_score']:.1f}%")
            print(f"   Total Findings: {len(analysis_results['findings'])}")
            
            # Show top priority improvements
            if analysis_results["ai_insights"]["improvement_priorities"]:
                print(f"   Top Priorities:")
                for priority in analysis_results["ai_insights"]["improvement_priorities"][:3]:
                    print(f"   - {priority['issue_type']}: {priority['count']} issues")
        
        return 0
        
    except Exception as e:
        logger.error(f"Agent execution failed: {e}")
        return 1


if __name__ == "__main__":
    sys.exit(main())