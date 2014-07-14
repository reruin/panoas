package
{
    import flash.display.Sprite
    
    public class ListExample extends Sprite
    {
        import fl.controls.Button;
        import fl.controls.Label;
        import fl.controls.List;
        import fl.data.DataProvider;
        import flash.events.*;
        
        private var clearButton:Button;
        private var availableItems:List;
        private var selectedItemList:List;
        private var selectedItemsList:List;

        public function ListExample() {
            createComponents();
            setupComponents();
        }

        private function setupComponents():void {
            var dp:Array = new Array();
            var i:uint;
            var count:uint = availableItems.rowCount * 2;
            
            for (i = 0; i < count; i++) {
                dp.push({label:"Item " + i});
            }
            
            availableItems.allowMultipleSelection = true;
            availableItems.dataProvider = new DataProvider(dp);
            availableItems.dataProvider = new DataProvider(dp);
            availableItems.addEventListener(Event.CHANGE, updateLists);
            clearButton.addEventListener(MouseEvent.CLICK, clearHandler);            
        }
        
        private function clearHandler(event:MouseEvent):void {
            availableItems.clearSelection();
            // clear data providers
            selectedItemList.dataProvider = new DataProvider();
            selectedItemsList.dataProvider = new DataProvider();
        }
        
        private function updateLists(e:Event):void {
            selectedItemList.dataProvider = availableItems.selectedItem ? new DataProvider([availableItems.selectedItem]) : new DataProvider();
            selectedItemsList.dataProvider = new DataProvider(availableItems.selectedItems);
        }

        private function createComponents():void {
            clearButton = new Button();
            availableItems = new List();
            selectedItemList = new List();
            selectedItemsList = new List();
            var availableItemsLabel:Label = new Label();
            var selectedItemListLabel:Label = new Label();
            var selectedItemsListLabel:Label = new Label();
            
            clearButton.move(10,142);
            availableItems.move(10,32);
            selectedItemList.move(120,32);
            selectedItemsList.move(230,32);
            availableItemsLabel.move(10,10);
            selectedItemListLabel.move(120,10);
            selectedItemsListLabel.move(230,10);
            
            clearButton.label = "Clear Selection"
            availableItemsLabel.text = "Available Items";
            selectedItemListLabel.text = "Selected Item";
            selectedItemsListLabel.text = "All Selected Items";
            
            addChild(clearButton);
            addChild(availableItems);
            addChild(selectedItemList);
            addChild(selectedItemsList);
            addChild(availableItemsLabel);
            addChild(selectedItemListLabel);
            addChild(selectedItemsListLabel);
        }
    }
}