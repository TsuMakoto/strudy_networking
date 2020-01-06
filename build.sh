cat README.md > index.md

for f in `ls **/README.md`
do
  cat $f >> index.md
done

for f in `ls **/**/*.ipynb`
do
  `which docker` run --rm --mount type=bind,src=`pwd`,dst=/home/jovyan jupyter/datascience-notebook jupyter nbconvert --to markdown $f
  mv `dirname $f`/`basename $f .ipynb`.md `dirname $f`/index.md
done
