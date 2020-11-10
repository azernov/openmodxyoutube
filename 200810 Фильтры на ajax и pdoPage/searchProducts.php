<?php

/**
 * РАЗБОР переменной layout
 */
$layout = $modx->getOption('layout', $_REQUEST, 'list');
switch ($layout) {
    default:
    case 'list':
        $scriptProperties['tpl'] = $scriptProperties['tplList'];
        break;
    case 'cell':
        $scriptProperties['tpl'] = $scriptProperties['tplCell'];
        break;
}

/**
 * Разбор переменной sort
 */
$allowedSortBy = ['id', 'Data.price', 'pagetitle'];
$allowedSortDir = ['asc', 'desc'];
$sort = $modx->getOption('sort', $_REQUEST, 'id:asc');
list($sortBy, $sortDir) = explode(':', $sort);
if (!in_array($sortBy, $allowedSortBy)) $sortBy = $allowedSortBy[0];
if (!in_array($sortDir, $allowedSortDir)) $sortDir = $allowedSortDir[0];
$scriptProperties['sortby'] = json_encode([
    $sortBy => $sortDir
]);

/**
 * Разбор переменных option_
 */
$optionFilters = [];
foreach ($_REQUEST as $key => $value) {
    if (strpos($key, 'option_') === false) continue;
    $realKey = substr($key, 7);
    $optionFilters[$realKey . ":IN"] = $value;
}
$scriptProperties['optionFilters'] = json_encode($optionFilters);


//Задать те параметры, по которым делается поиск
$integerSearchParams = [
    'Data.price' => ['price_from', 'price_to'],
    'Data.massa' => ['massa_from', 'massa_to'],
];

foreach($integerSearchParams as $filteredParam => $paramNames) {
    /**
     * Разбор поля price_from price_to
     */
    $from = $modx->getOption($paramNames[0], $_REQUEST, '0');
    $to = $modx->getOption($paramNames[1], $_REQUEST, '');
    $where = [];
    if ($from) {
        $priceFrom = intval($from, 10);
        $where[$filteredParam.':>='] = $from;
    }
    if ($to) {
        $to = intval($to, 10);
        $where[$filteredParam.':<='] = $to;
    }
}


/**
 * Разбор параметра term
 */
$term = $modx->getOption('term', $_REQUEST, '');
if($term) {
    $where[0] = [];
    //Экранируем спецсимволы для выражения LIKE
    $term = str_replace(['_', '%', '+', '?'], ['\_', '\%', '\+', '\?'], $term);
    $where[0]['pagetitle:LIKE'] = '%' . $term . '%';
    $where[0]['OR:introtext:LIKE'] = '%' . $term . '%';
}


if(!empty($where)){
    $scriptProperties['where'] = json_encode($where);
}

return $modx->runSnippet('msProducts', $scriptProperties);