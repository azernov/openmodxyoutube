<?php
/**
 * Скрипт для непрямого доступа к файлам/материалам курса
 * Нужен для проверки авторизации пользователя
 */

define("MODX_API_MODE", true);
require dirname(dirname(dirname(__DIR__))) . '/index.php';

$modx->loadClass('lectshop.leutils', MODX_CORE_PATH . 'components/lectshop/model/', false, true);
//Делаем инициализацию базовых сервисов, без них выдает ошибку при редиректе
if (!isset($modx->lexicon)) $modx->getService('lexicon', 'modLexicon');
if (!isset($modx->error)) $modx->getService('error', 'error.modError');

//Имя файла, относительно базового каталога MODX
$file = ltrim($_REQUEST['file'], '/');
//Имя файла без базовой части защищенного каталога
$basePath = $modx->getOption('le_auth_files_path');
$fileWithoutAuthBasePath = preg_replace('#^' . preg_quote($basePath) . '#', '', $file);
//Полный путь к файлу
$fullFilePath = MODX_BASE_PATH . $basePath . $file;
$fileFound = false;

/** @var modUser $user */
$user = &$modx->user;

//Проверяем, есть ли вообще этот файл
if (!file_exists($fullFilePath)) {
    $modx->sendErrorPage();
    exit;
}

//проверить, является ли файл защищенным
$pageId = $_REQUEST['pageId'];
$protected = true;
if($pageId){
    /** @var modResource $resource */
    $resource = $modx->getObject('modResource', $pageId);
    if($resource){
        $tv = $resource->getTVValue('supportFiles');
        if(is_string($tv)){
            $tv = json_decode($tv, true);
        }

        foreach($tv as $resourceFile){
            if(strtolower($resourceFile['file']) == strtolower($fileWithoutAuthBasePath) && $resourceFile['protected'] != 1){
                $protected = false;
            }
        }
    }
}

//Проверяем, авторизован ли пользователь на frontend
if ($protected && (!$user || !$user->hasSessionContext($modx->context->key))) {
    $modx->sendUnauthorizedPage();
    exit;
}

//Отдаем файл
leUtils::downloadFile($fullFilePath,1000, false);
exit;
