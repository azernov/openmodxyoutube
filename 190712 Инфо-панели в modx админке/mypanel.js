/**
 * Скрипт, добавляющий инфо-панель в форму редактирования ресурса
 */

Ext.onReady(function(){
    var cmp = Ext.getCmp('modx-panel-resource');
    cmp.insert(1, {
        layout: 'form',
        header: false,
        autoHeight: true,
        collapsible: true,
        items: [{
            id: 'my-help-panel',
            html: '<p>' + myHelpConfig.text + '</p>',
            xtype: 'modx-description',
            cls: 'main-wrapper'
        }]
    });

    cmp.doLayout();

});