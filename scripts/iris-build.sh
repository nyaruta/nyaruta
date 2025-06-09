rm builder.config.json && touch builder.config.json

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

# Build the Iris project
pnpm run build
