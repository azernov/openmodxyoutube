<?php
require_once MODX_CORE_PATH.'model/modx/processors/search/search.class.php';

class searchResourcesProcessor extends modSearchProcessor {
    public function process() {
        $this->query = $this->getProperty('query');
        if (!empty($this->query)) {
            // Search elements & resources
            $this->searchResources();
        }

        return $this->outputArray($this->results);
    }
}

return 'searchResourcesProcessor';