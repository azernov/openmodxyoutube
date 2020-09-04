<?php
require_once MODX_CORE_PATH . 'model/modx/modprocessor.class.php';

class omTestGetListProcessor extends modProcessor {

    /**
     * Run the processor and return the result. Override this in your derivative class to provide custom functionality.
     * Used here for pre-2.2-style processors.
     *
     * @return mixed
     */
    public function process()
    {
        $start = $this->getProperty('start');
        $limit = $this->getProperty('limit');
        $sort = $this->getProperty('sort');
        $dir = $this->getProperty('dir');


        $criteria = $this->modx->newQuery('modResource');
        $criteria->sortby($sort, $dir);
        $criteria->limit($limit, $start);
        /** @var modResource[] $resources */
        $resources = $this->modx->getCollection('modResource', $criteria);

        $objects = [];
        foreach($resources as $resource){
            $objects[] = $resource->toArray();
        }

        $count = false;
        if ($count === false) { $count = count($objects); }
        $output = json_encode(array(
            'success' => true,
            'total' => $this->modx->getCount('modResource'),
            'results' => $objects
        ));
        if ($output === false) {
            $this->modx->log(modX::LOG_LEVEL_ERROR, 'Processor failed creating output array due to JSON error '.json_last_error());
            return json_encode(array('success' => false));
        }
        return $output;
    }
}

return 'omTestGetListProcessor';