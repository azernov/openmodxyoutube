<?php
/**
 * хук для отправки файла на почту пользователя
 * @var fiHooks $hook
 */

$emailTpl = $hook->config['emailToUserTpl'];
$userEmailField = $hook->config['emailToUserEmailField'] ?: 'email';
$emailSubject = $hook->config['emailToUserSubject'] ?: $modx->config['site_name'];

$resourceId = $hook->getValue('resourceId');
if(!$resourceId){
    $hook->addError('resourceId', 'Ошибка. Не указан проект.');
    return false;
}

/** @var modResource $resource */
$resource = $modx->getObject('modResource', $resourceId);
if(!$resource || $resource->get('template') != $modx->getOption('in_house_template_id')){
    $hook->addError('resourceId', 'Ошибка. Не найден такой проект.');
    return false;
}

if(!$emailTpl) {
    $hook->addError($userEmailField, 'Не указан шаблон письма. Обратитесь в техподдержку');
    return false;
}

/** @var pdoFetch $pdoFetch */
$pdoFetch = $modx->getService('pdoFetch', 'pdoFetch');
$emailSubject = $pdoFetch->getChunk('@INLINE'.$emailSubject, $resource->toArray());

$files = [];

//TODO измените логику на свою, чтобы прикреплять свои файлы к письму. в $files необходимо добавить абсолютные пути к файлам

//1. Получаем картинки проекта дома
/** @var msResourceFile[] $galleryFiles */
$modx->loadClass('msResourceFile', MODX_CORE_PATH.'components/ms2gallery/model/ms2gallery/');
if($galleryFiles = $modx->getCollection('msResourceFile', [
    'parent' => 0,
    'resource_id' => $resourceId,
    'active' => 1
])){
    foreach($galleryFiles as $galleryFile){
        $files[] = MODX_ASSETS_PATH.'images/resources/'.$galleryFile->get('path').$galleryFile->get('file');
    }
}

//2. Получаем картинки из TV migx
if($planMigxData = $resource->getTVValue('housePlans')){
    $planMigxData = json_decode($planMigxData, true);
    foreach($planMigxData as $item){
        $files[] = MODX_ASSETS_PATH.'files/'.$item['schematicImage'];
        $files[] = MODX_ASSETS_PATH.'files/'.$item['renderedImage'];
    }
}


$modx->getService('mail', 'mail.modPHPMailer');
/** @var modPHPMailer $mail */
$mail = &$modx->mail;
/** @var PHPMailer $mailer */
$mailer = &$mail->mailer;

$emailBody = $pdoFetch->getChunk($emailTpl);

$mail->set(modMail::MAIL_BODY, $emailBody);
$mail->set(modMail::MAIL_FROM, $modx->config['emailsender']);
$mail->set(modMail::MAIL_FROM_NAME, $modx->config['site_name']);
$mail->set(modMail::MAIL_SUBJECT, $emailSubject);
$mail->address('to', $hook->getValue($userEmailField));
$mail->setHTML(true);

if($files && is_array($files)) {
    foreach ($files as $file) {
        try {
            $fileName = basename($file);
            $mailer->AddAttachment($file, $fileName);
        } catch (Exception $e) {

        }
    }
}

if(!$mail->send()){
    $modx->log(
        modX::LOG_LEVEL_ERROR,
        'An error occurred while trying to send the email: '.$mailer->ErrorInfo
    );
    $hook->addError($userEmailField, 'При попытке отправить материалы произошла ошибка. Обратитесь в техподдержку.');
    return false;
}
$mail->reset();
return true;