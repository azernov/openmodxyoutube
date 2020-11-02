<item turbo="true">
    <!-- Информация о странице -->
    <link>{$id | url : ['scheme' => 'full']}</link>
    <turbo:source>{$id | url : ['scheme' => 'full']}</turbo:source>
    <turbo:topic>{$pagetitle | htmlent}</turbo:topic>
    <pubDate>{$publishedon | date : 'r'}</pubDate>
    <author></author>
    <metrics>
        {* TODO добавьте мета-тег в head страницы: <meta itemprop="identifier" content="{$id~$uri~'nai9gn391' | md5}"> *}
        <yandex schema_identifier="{$id~$uri~'nai9gn391' | md5}">
            {'pdoCrumbs' | snippet : [
                'to' => $id,
                'tplWrapper' => '@INLINE <breadcrumblist>{$output}</breadcrumblist>',
                'tpl' => '@INLINE <breadcrumb url="{$link}" text="{$pagetitle | htmlent}"/>',
                'tplCurrent' => '@INLINE <breadcrumb url="{$link}" text="{$pagetitle | htmlent}"/>',
                'tplHome' => '@INLINE <breadcrumb url="{$link}" text="{$pagetitle | htmlent}"/>',
                'showHome' => '1',
                'scheme' => 'full',
            ]}
        </yandex>
    </metrics>
    <turbo:content>
        <![CDATA[
        <header>
            <h1>{$longtitle ?: $pagetitle}</h1>
        </header>
        {$content | processForRss}
        ]]>
    </turbo:content>
</item>