# Hello API Challenge

Simple Express backend with `/sayHello` running on **port 80**, and a **GitHub Actions** pipeline that deploys to a VM via SSH **without any `git pull` on the VM** and **no secrets stored on the VM**.

## API
- `GET /sayHello` → `{ "message": "Hello User." }`
- Port: **80**

## Local run (optional)
```bash
npm install
sudo node index.js   # Needs privileged port. Alternatively, use: sudo setcap 'cap_net_bind_service=+ep' $(readlink -f $(which node)) && node index.js
```

## Files
```
.
├─ index.js                     # Express server on :80
├─ package.json
├─ .gitignore
├─ deploy/
│  ├─ helloapi.service          # systemd unit (bind :80 as non-root using capabilities)
│  ├─ setup_on_vm.sh            # one-time prepare (Node install, systemd, enable service)
│  └─ deploy_on_vm.sh           # used by Actions on each deploy
└─ .github/workflows/deploy.yml # GitHub Actions workflow
```

## One-time VM preparation
> VM: `azureuser@20.127.201.13` (Ubuntu assumed)

1. Ensure your SSH public key is in `~/.ssh/authorized_keys` on the VM (already done by challenge).
2. Open port 80 in firewall/NSG (Azure Portal → Networking → inbound rule for TCP/80).
3. The first successful GitHub Actions run will perform setup via systemd automatically.

## GitHub
1. Create a **private** repo and push these files.
2. In **Repo → Settings → Secrets and variables → Actions → New repository secret**, add:
   - `SSH_HOST` = `20.127.201.13`
   - `SSH_USER` = `azureuser`
   - `SSH_PRIVATE_KEY` = *paste the PEM private key contents*
3. Push to the default branch (e.g., `main`) to trigger `deploy.yml`.

## What the workflow does
- Checks out your code
- Sets up SSH (writes your `SSH_PRIVATE_KEY` to an ephemeral file)
- `rsync` your repo contents to the VM (no `git pull` on VM)
- Installs production dependencies on the VM
- Installs/updates a `systemd` service and restarts it

## Test
After deploy:
```bash
curl http://20.127.201.13/sayHello
# -> {"message":"Hello User."}
```

## Notes
- **No secrets on VM**: None are written; the key is only used by Actions agent.
- **No manual code on VM**: Code is copied by CI; do not `git pull` on VM.
- If binding to `:80` fails, check:
  - `sudo systemctl status helloapi -l`
  - That `AmbientCapabilities=CAP_NET_BIND_SERVICE` is supported (Ubuntu 18.04+ OK).
  - Alternatively run `sudo setcap 'cap_net_bind_service=+ep' $(readlink -f $(which node))` once.

## Security
Rotate/replace the private key after the assessment.
```bash
# (Optional) Remove capability later
sudo setcap -r $(readlink -f $(which node))
```"# hello-api-challenge" 
