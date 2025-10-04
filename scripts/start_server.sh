#!/bin/bash
set -euxo pipefail
systemctl enable httpd
systemctl restart httpd
