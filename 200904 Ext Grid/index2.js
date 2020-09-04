var myGrid = function (config) {
    config = config || {};
    sm = new Ext.grid.CheckboxSelectionModel({singleSelect: false});
    Ext.applyIf(config,{
        url: '/assets/components/openmodx/connector.php',
        baseParams: {
            action: 'mgr/testgetlist',
            myParam: 'test'
        },
        paging: true,
        pageSize: 10,
        remoteSort: true,
        sm: sm,
        fields: ['id', 'pagetitle', 'introtext'],
        tbar: [{
            xtype: 'button',
            text: 'Ok',
            handler: function(e){
                var items = this.getSelectionModel().getSelections();
                if(items.length > 0){
                    alert('Вы выбрали: '+items[0].data.pagetitle);
                }
            }
        },'->',{
            xtype: 'button',
            text: 'Вторая кнопочка',
        }],
        columns: [sm, {
            dataIndex: 'id',
            header: 'ID',
            sortable: true,
        },{
            dataIndex: 'pagetitle',
            header: 'Заголовок',
            sortable: true,
        },{
            dataIndex: 'introtext',
            header: 'Вводный текст',
        }],
    });
    myGrid.superclass.constructor.call(this, config);
};
Ext.extend(myGrid, MODx.grid.Grid, {
    getMenu: function() {
        var m = [];
        var items = this.getSelectionModel().getSelections();
        if(items.length > 1) {
            m.push({
                text: 'Пункт меню для множественного выделения',
                handler: function(e){
                    alert('Меня кликнули. Количество выделений: '+items.length);
                }
            });
        }
        else if(items.length == 1){
            m.push({
                text: 'Пункт меню для одного выделения',
                handler: function(e){
                    alert('Меня кликнули');
                }
            });
        }
        return m;
    }
});
Ext.reg('my-grid', myGrid);