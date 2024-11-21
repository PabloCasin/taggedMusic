for file in *.mp3; do
  new_name=$(echo "$file" | sed 's/^A1\. //')
  mv "$file" "$new_name"
done