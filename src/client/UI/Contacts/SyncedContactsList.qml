// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import "../common"
import "../common/WAListView"

WAPage{
    id:contactsSelectorPage
    property alias title:header.title
    property alias multiSelectmode:contactlist.multiSelectMode
    property bool showGroups: false
    
    signal selected(variant selectedItem);
    
    function getSelected(){
	return contactlist.getSelected()
    }
    
    function resetSelections(){
	contactlist.resetSelections()
	consoleDebug("test contactsModel")
	for(var j =0; j<contactsModel.count; j++) {
	    consoleDebug(contactsModel.get(j).jid)
	}
    }
    
    function positionViewAtBeginning (){
	contactlist.positionViewAtBeginning()
    }
    
    function unbindSlots(){
	selected.disconnect()
	showGroups = false
    }
    
    function getContactsModel(){
	selectorModel.clear()
	var contactsmodel = getContacts()
	for (var i=0; i<contactsmodel.count; i++){
	    selectorModel.append(contactsmodel.get(i))
	}
	return selectorModel;
    }
    
    function getMixedModel(){
	selectorModel.clear()
	var contactsmodel = getContacts()
	var groupsmodel = getGroups()
	for (var i=0; i<contactsmodel.count; i++){
	    selectorModel.append(contactsmodel.get(i))
	}
	for (var i=0; i<groupsmodel.count; i++){
	    selectorModel.append(groupsmodel.get(i))
	}
	return selectorModel;
    }
    
    function getModel(){
	if (showGroups)
	    return getMixedModel()
	else
	    return getContactsModel()
    }
    
    function select(ind){return contactlist.select(ind);}
    function unSelect(ind){return contactlist.unSelect(ind);}
    
    ListModel{
	id: selectorModel
    }    
    
    WAHeader{
	id:header
	anchors.top:parent.top
	width:parent.width
	height: 73
    }
    
    WAListView{
	id: contactlist
	defaultPicture: defaultProfilePicture
	    anchors.top:header.bottom
	    useRoundedImages: false
	    model: getModel()
	    
	    onSelected:{ consoleDebug("from contacts"); contactsSelectorPage.selected(selectedItem);}
    }
    
}
