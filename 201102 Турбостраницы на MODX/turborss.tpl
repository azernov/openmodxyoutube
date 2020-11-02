<?xml version="1.0" encoding="UTF-8"?>
<rss xmlns:yandex="http://news.yandex.ru"
     xmlns:media="http://search.yahoo.com/mrss/"
     xmlns:turbo="http://turbo.yandex.ru"
     version="2.0">
    <channel>
        <!-- Информация о сайте-источнике -->
        <title>{'site_name' | option}</title>
        <link>{'site_url' | option}</link>
        <description>Какое-то описание</description>
        <language>{'cultureKey' | option}</language>
        {'pdoResources' | snippet : [
            'tpl' => 'e.turboRssItem',
            'parents' => '17',
            'limit' => 0,
            'includeTVs' => '',
            'processTVs' => '',
            'tvPrefix' => '',
            'sortby' => '{"publishedon":"ASC"}',
            'includeContent' => 1,
        ]}
    </channel>
</rss>