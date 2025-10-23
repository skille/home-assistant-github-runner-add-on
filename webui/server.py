#!/usr/bin/env python3
"""
Simple web UI server for GitHub Actions Runner add-on.
Provides a button to unregister the runner.
"""

import os
import subprocess
import json
import logging
from flask import Flask, render_template, jsonify, request

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Path to options file
OPTIONS_FILE = "/data/options.json"
RUNNER_DIR = "/runner"


def get_runner_token():
    """Get the runner token from the options file."""
    try:
        with open(OPTIONS_FILE, 'r') as f:
            options = json.load(f)
            return options.get('runner_token', '')
    except Exception as e:
        logger.error(f"Error reading options file: {e}")
        return None


@app.route('/')
def index():
    """Serve the main page."""
    return render_template('index.html')


@app.route('/api/unregister', methods=['POST'])
def unregister_runner():
    """Unregister the GitHub Actions runner."""
    try:
        logger.info("Unregister request received")
        
        # Get the runner token
        runner_token = get_runner_token()
        if not runner_token:
            return jsonify({
                'success': False,
                'message': 'Failed to read runner token from configuration'
            }), 500
        
        # Change to runner directory
        os.chdir(RUNNER_DIR)
        
        # Execute the unregister command as the runner user
        cmd = ['su', 'runner', '-c', f'./config.sh remove --token "{runner_token}"']
        logger.info(f"Executing unregister command")
        
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=30
        )
        
        if result.returncode == 0:
            logger.info("Runner unregistered successfully")
            return jsonify({
                'success': True,
                'message': 'Runner unregistered successfully. You may need to restart the add-on to register again.'
            })
        else:
            logger.error(f"Unregister failed: {result.stderr}")
            return jsonify({
                'success': False,
                'message': f'Failed to unregister runner: {result.stderr}'
            }), 500
            
    except subprocess.TimeoutExpired:
        logger.error("Unregister command timed out")
        return jsonify({
            'success': False,
            'message': 'Unregister command timed out'
        }), 500
    except Exception as e:
        logger.error(f"Error unregistering runner: {e}")
        return jsonify({
            'success': False,
            'message': f'Error: {str(e)}'
        }), 500


@app.route('/api/status', methods=['GET'])
def get_status():
    """Get the current runner status."""
    try:
        # Check if .runner file exists (indicates runner is configured)
        runner_file = os.path.join(RUNNER_DIR, '.runner')
        is_configured = os.path.exists(runner_file)
        
        status = 'configured' if is_configured else 'not_configured'
        
        return jsonify({
            'success': True,
            'status': status,
            'configured': is_configured
        })
    except Exception as e:
        logger.error(f"Error getting status: {e}")
        return jsonify({
            'success': False,
            'message': f'Error: {str(e)}'
        }), 500


if __name__ == '__main__':
    # Run the Flask app on port 8099 (Ingress will proxy to this)
    app.run(host='0.0.0.0', port=8099, debug=False)
