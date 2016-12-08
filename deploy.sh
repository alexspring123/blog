cp -R public/* .deploy
cd .deploy
git add *
git commit -m "deploy"
git push
cd ..