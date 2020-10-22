<?php
/**
 * Хук добавляет UTM метки к отправляемым данным формы
 * UTM берутся из $_SESSION['UTM']
 * @var fiHooks $hook
 */

if(!isset($_SESSION['UTM'])) return true;

foreach($_SESSION['UTM'] as $name => $value){
    $hook->setValue($name, $value);
}

return true;