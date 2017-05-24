xcopy public .deploy /s /e /y
cd .deploy
git add *
git commit -m "deploy"
git push
cd ..