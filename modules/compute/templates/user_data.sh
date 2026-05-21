#!/bin/bash
# ==============================================================================
# EC2 User Data Bootstrap Script
# Project: ${project_name} | Environment: ${environment}
# ==============================================================================
set -euxo pipefail

# --- System Updates ---
dnf update -y

# --- Install nginx ---
dnf install -y nginx

# --- Configure nginx ---
cat > /usr/share/nginx/html/index.html <<'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${project_name} | ${environment}</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: 'Segoe UI', system-ui, sans-serif;
      background: linear-gradient(135deg, #0f0c29, #302b63, #24243e);
      color: #e0e0e0;
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .container {
      text-align: center;
      padding: 3rem;
      background: rgba(255,255,255,0.05);
      border-radius: 20px;
      backdrop-filter: blur(10px);
      border: 1px solid rgba(255,255,255,0.1);
      max-width: 600px;
    }
    h1 { font-size: 2.5rem; margin-bottom: 1rem; color: #00d4ff; }
    .badge {
      display: inline-block;
      padding: 0.3rem 1rem;
      background: rgba(0,212,255,0.2);
      border: 1px solid #00d4ff;
      border-radius: 20px;
      font-size: 0.9rem;
      margin-bottom: 1.5rem;
    }
    .info { margin-top: 1rem; font-size: 0.85rem; opacity: 0.7; }
    .status { color: #00ff88; font-weight: bold; }
  </style>
</head>
<body>
  <div class="container">
    <h1>&#x1F6E1;&#xFE0F; ${project_name}</h1>
    <div class="badge">${environment}</div>
    <p>Infrastructure deployed via <strong>Terraform</strong></p>
    <p class="info">
      Instance: <span id="instance-id">loading...</span><br>
      AZ: <span id="az">loading...</span><br>
      Status: <span class="status">&#x2705; Healthy</span>
    </p>
  </div>
  <script>
    // Fetch instance metadata (IMDSv2)
    async function getMeta() {
      try {
        const tokenRes = await fetch('http://169.254.169.254/latest/api/token', {
          method: 'PUT', headers: { 'X-aws-ec2-metadata-token-ttl-seconds': '21600' }
        });
        const token = await tokenRes.text();
        const headers = { 'X-aws-ec2-metadata-token': token };
        const [idRes, azRes] = await Promise.all([
          fetch('http://169.254.169.254/latest/meta-data/instance-id', { headers }),
          fetch('http://169.254.169.254/latest/meta-data/placement/availability-zone', { headers })
        ]);
        document.getElementById('instance-id').textContent = await idRes.text();
        document.getElementById('az').textContent = await azRes.text();
      } catch(e) {
        document.getElementById('instance-id').textContent = 'N/A';
        document.getElementById('az').textContent = 'N/A';
      }
    }
    getMeta();
  </script>
</body>
</html>
HTMLEOF

# --- Configure nginx to listen on the correct port ---
cat > /etc/nginx/conf.d/${project_name}.conf <<NGINXEOF
server {
    listen ${app_port};
    server_name _;

    location / {
        root /usr/share/nginx/html;
        index index.html;
    }

    location /health {
        access_log off;
        return 200 'OK';
        add_header Content-Type text/plain;
    }
}
NGINXEOF

# --- Start and enable nginx ---
systemctl enable nginx
systemctl start nginx

# --- Verify nginx is running ---
curl -s http://localhost:${app_port}/health || echo "WARNING: nginx health check failed"

echo "=== Bootstrap complete ==="
