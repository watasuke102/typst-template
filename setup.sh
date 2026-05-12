#!/usr/bin/env sh

if [[ -e $HOME/.local/share/typst/packages/watasuke102 ]]; then
  echo "Already installed."
  exit 1
fi

mkdir -p $HOME/.local/share/typst/packages
git clone https://github.com/watasuke102/typst-template $HOME/.local/share/typst/packages/watasuke102
cat << EOF > $HOME/.local/share/typst/packages/watasuke102/report/1.3.0/properties.typ
#let student_name = "田中太郎"
#let student_id   = "12345"
EOF

echo -e '\e[32mInstalled successfully.\e[0m'
ls -l $HOME/.local/share/typst/packages/watasuke102

