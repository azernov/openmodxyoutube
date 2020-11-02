<?php
/** @var pdoFetch $pdoFetch */
$parser = $modx->getParser();
$regexp = '#\[\[\$e\.newsInContentSubscribe\??([ \n\t\s]*&?[^=]+=`[^`]*`)*[ \n\t\s]*\]\]#muU';
//Удаляем формы подписки из контента
$input = preg_replace($regexp, '', $input);

//Обрабатываем все теги
$parser->processElementTags('', $input);

//А потом делаем пути абсолютными
$input = preg_replace('#(src|href)=([\'"])(assets/)#mui', '$1=$2'.$modx->getOption('site_url').'$3', $input);
return $input;