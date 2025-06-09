echo "[+] Removing configs"
rm builder.config.json config.json

echo "[+] Writing configs"
cat > builder.config.json <<EOF
{
  "repo": {
    "enable": false,
    "url": ""
  }
}
EOF

cat > config.json <<EOF
{
  "name": "Dress",
  "title": "Dress",
  "description": "Dress pictures of CTO",
  "url": "https://gallery.chitang.org",
  "accentColor": "#007bff",
  "ogImage": {
    "width": 1200,
    "height": 630
  },
  "author": {
    "name": "CTO",
    "url": "https://chitang.org"
  },
  "extra": {
    "accessRepo":false
  }
}
EOF

echo "[+] Updaing manifest"
pnpm --filter @photo-gallery/web build:manifest
echo "[+] Starting build"
pnpm run build
