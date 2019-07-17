<?php

define("MODX_API_MODE", true);
include dirname(dirname(dirname(__DIR__))).'/index.php';

$query = $_GET['query'];

//TODO убрать ненужные элементы из запроса

/** @var modProcessorResponse $result */
$result = $modx->runProcessor('searchresources',[
    'query' => $query
],[
    'processors_path' => MODX_CORE_PATH.'components/mysite/processors/'
]);

header('Content-type: text/json');
echo $result->response;
exit;