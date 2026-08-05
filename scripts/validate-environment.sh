#!/usr/bin/env bash
# Runs the Master Validation Checklist commands from the installation guide.
set -e
echo "Checking Java..."; java -version
echo "Checking Maven..."; mvn -version
echo "Checking Docker..."; docker --version
echo "Checking Git..."; git --version
echo "Checking Python..."; python3 --version
echo "Checking Poetry..."; poetry --version
echo "Checking AWS CLI..."; aws --version
echo "Checking Terraform..."; terraform -version
echo "All checks passed."
