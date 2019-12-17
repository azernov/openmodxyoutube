<?php
/**
 * Плагин для выдачи ошибки, при отсутствии авторизации на страницах, где требуется авторизация
 */
if($modx->event->name != 'OnLoadWebDocument') return '';

if ($modx->resource) {
    $template = $modx->resource->get('template');
    $templatesArray = $modx->getOption('your_authorized_templates');

    //Если список шаблонов - это строка, то предполагаем, что это список ID шаблонов, разделенных запятой
    if(!is_string($templatesArray)) $templatesArray = explode(',',$templatesArray);

    //Если шаблон требует авторизацию и пользователь не авторизован, то выдаем страницу ошибки
    if(in_array($template, $templatesArray) && !$modx->user->hasSessionContext($modx->context->key)){
        //Вместо in_array($template, $templatesArray) можно разместить любую другую логику, которая соответствует вашему проекту
        //Например $modx->resource->getTVValue('need_auth')
        //Или $modx->resource->id == ....

        //В системной настройке your_unauthorized_page_id должен лежать ID ресурса с ошибкой
        $modx->sendForward($modx->getOption('your_unauthorized_page_id'), [
            'merge' => 1, // Включает механизм склейки полей
            // список оригинальных полей, которые нужно исключить из результата
            'forward_merge_excludes' => 'id,template,class_key',
            'response_code' => $_SERVER['SERVER_PROTOCOL'] . ' 401 Unauthorized',
        ]);
        exit;
    }
}