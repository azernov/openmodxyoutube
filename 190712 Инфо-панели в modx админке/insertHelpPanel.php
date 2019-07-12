<?php
/**
 * Плагин для внедрения js кода в админке
 */

if($modx->event->name != 'OnDocFormPrerender' || $modx->context->key != 'mgr'){
    return;
}

$template = $resource->get('template');

if($template == 1){
    $text = 'Это хелп-текст для первого шаблона';
}
elseif($template == 9){
    $text = 'Другой хелп-текст';
}
else{
    return;
}

$configJs = json_encode([
    'text' => $text
]);

$config = <<<HTML
<script>
    var myHelpConfig = {$configJs};
</script>
HTML;

$modx->controller->addHtml($config);

$script = MODX_ASSETS_URL . 'components/mysite/js/mgr/mypanel.js';

$modx->controller->addLastJavascript($script);