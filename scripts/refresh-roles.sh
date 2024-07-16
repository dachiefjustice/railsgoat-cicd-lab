#!/bin/bash

# Run this from the project root to install/update externally-managed roles

# Install project roles (refresh roles stored in upstream repos)
ansible-galaxy install -r roles/requirements.yml