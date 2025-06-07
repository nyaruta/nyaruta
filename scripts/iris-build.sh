cat > builder.config.json <<EOF
{
  "provider": "github",
  "github": {
    "owner": env.OWNER,
    "repo": env.REPO,
    "token": env.GH_TOKEN,
    "useRawUrl": true
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
  "social": {
    "twitter": "@nyaaruta"
  },
  "extra": {
    "accessRepo":false
  }
}
EOF

# Build the Iris project
pnpm run build