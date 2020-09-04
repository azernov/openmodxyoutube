<?php
require_once MODX_CORE_PATH.'model/modx/modmanagercontroller.class.php';

class OpenmodxIndex2ManagerController extends modExtraManagerController {
    /**
     * Do any page-specific logic and/or processing here
     * @param array $scriptProperties
     * @return void
     */
    public function process(array $scriptProperties = array()) {}

    /**
     * The page title for this controller
     * @return string The string title of the page
     */
    public function getPageTitle() { return 'Наша страничка'; }

    /**
     * Loads any page-specific CSS/JS for the controller
     * @return void
     */
    public function loadCustomCssJs() {
        $baseUrl = '/assets/components/openmodx/';
        $this->addLastJavascript($baseUrl.'js/mgr/index2.js');
        $resource = $this->modx->getObject("modResource", 1);
        $resourceData = json_encode($resource->toArray());
        $html = <<<HTML
<script>
Ext.onReady(function(){
    MODx.add({
        xtype: 'my-grid',
    });
});
</script>
HTML;

        $this->addHtml($html);
    }

    /**
     * Specify the location of the template file
     * @return string The absolute path to the template file
     */
    public function getTemplateFile() {
        return '';//dirname(__DIR__).'/templates/index.tpl';
    }

    /**
     * Check whether the active user has access to view this page
     * @return bool True if the user passes permission checks
     */
    public function checkPermissions() { return true;}
}