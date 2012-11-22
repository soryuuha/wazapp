import QtQuick 1.1
import com.nokia.meego 1.0
import "../common/js/Global.js" as Helpers
import "../common/js/settings.js" as MySettings;
import "js/emojihelper.js" as EmojiHelper
import QtMobility.feedback 1.1
import "Components"
import "../common"

Dialog {
	id: emojiSelector
	
	width: parent.width
	height: parent.height


    property string titleText: qsTr("Select Emoji")
    property string emojiPath:"../common/images/emoji/";
    property string emojiRelativePath; //relative to textfield
    property variant currentGrid: peopleGrid;
    property bool longDialog: false

    /*function setCallback(func){

        EmojiHelper.emojiSelectCallback = func;

    }*/
    
    ThemeEffect {
      id: feedbackEffect
      effect: "BasicButton"
    }

    function get32(code){
        var c = ""+code;
        return emojiPath+"32/"+c+".png";
    }

    function get20(code){
        var c = ""+code;
        return emojiPath+"20/"+c+".png";
    }

    function get24(code){
        var c = ""+code;
        return emojiPath+"24/"+c+".png";
    }
    
    function openLongDialog(textarea, relativePath){
	openDialog(textarea, relativePath)
	longDialog = true;
    }

    function openDialog(textarea, relativePath){
        if(!textarea){
            consoleDebug("NO TEXTAREA SPECIFIED FOR EMOJI, NOT OPENING!")
            return;
        }
        textarea.lastPosition = textarea.cursorPosition
        EmojiHelper.emojiTextarea = textarea


        emojiRelativePath = relativePath?relativePath:"/opt/waxmppplugin/bin/wazapp/UI/common/images/emoji"

        emojiSelector.open();
        showGrid(currentGrid)
        longDialog = false
    }

    function getGrids(){
        return [recentGrid, peopleGrid, natureGrid, objectsGrid, placesGrid, symbolsGrid];
    }

    function loadAll(){
        var grids = getGrids();

        for(var g in grids){
            grids[g].loadEmoji();
        }
    }

    function hideAll(){
        var grids = getGrids();
        for(var g in grids){
            grids[g].visible = false;
        }
    }

    function showGrid(grid){
        hideAll();
        currentGrid = grid;
        grid.showEmoji();
    }
    
	SelectionDialogStyle { id: selectionDialogStyle }

    title: Item {
    	id: header
        height: selectionDialogStyle.titleBarHeight
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        Item {
            id: labelField
            anchors.fill:  parent

            Item {
                id: labelWrapper
                anchors.left: labelField.left
                anchors.right: closeButton.left
                anchors.bottom:  parent.bottom
                anchors.bottomMargin: selectionDialogStyle.titleBarLineMargin
                height: titleLabel.height

                Label {
                    id: titleLabel
                    x: selectionDialogStyle.titleBarIndent
                    width: parent.width - closeButton.width
                    font: selectionDialogStyle.titleBarFont
                    color: selectionDialogStyle.commonLabelColor
                    elide: selectionDialogStyle.titleElideMode
                    text: emojiSelector.titleText
                }

            }

            Image {
                id: closeButton
                anchors.bottom:  parent.bottom
                anchors.bottomMargin: selectionDialogStyle.titleBarLineMargin-6
                anchors.right: labelField.right
                opacity: closeButtonArea.pressed ? 0.5 : 1.0
                source: "image://theme/icon-m-common-dialog-close"

                MouseArea {
                    id: closeButtonArea
                    anchors.fill: parent
                    onClicked:  {emojiSelector.reject();}
                }
            }
        }

        Rectangle {
            id: headerLine
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom:  header.bottom
            height: 1
            color: "#4D4D4D"
        }

    }

	content: Item {
        width: parent.width
		height: emojiSelector.height-200

        ButtonRow {
            id: emojiCategory
            checkedButton: peopleEmoji
            anchors.horizontalCenter: parent.horizontalCenter
           // width: emojiSelector.width-30
            y: 10

            WAButton {
                id: recentEmoji
                styleSuffix: "-horizontal-left"
                iconSource: get32("E02C");
                onClicked: showGrid(recentGrid)
            }

            WAButton {
                id: peopleEmoji
                styleSuffix: "-horizontal-center"
                iconSource: get32("E057");
                onClicked: showGrid(peopleGrid)
            }

            WAButton {
                id: natureEmoji
                styleSuffix: "-horizontal-center"
                iconSource: get32("E303");
                onClicked: showGrid(natureGrid)
            }

            WAButton {
                id: placesEmoji
                styleSuffix: "-horizontal-center"
                iconSource: get32("E325")
                onClicked: showGrid(placesGrid)
            }

            WAButton {
                id: objectsEmoji
                styleSuffix: "-horizontal-center"
                iconSource: get32("E036")
                onClicked: showGrid(objectsGrid)
            }

            WAButton {
                id: symbolsEmoji
                styleSuffix: "-horizontal-right"
                iconSource: get32("E210")
                onClicked: showGrid(symbolsGrid)
            }
        }

        Rectangle {
            id:emojiContainer
            width: parent.width
            height: emojiSelector.height-200
           // radius: 20
            anchors.top:emojiCategory.bottom
            anchors.topMargin: 5
            color: "#000000"//"#1a1a1a"

            EmojiGrid{
                id:recentGrid
                anchors.fill: parent
                showRecent: true
            }

            EmojiGrid{
                id:peopleGrid
                anchors.fill: parent
                start: 0;
                end: 188;
            }

            EmojiGrid{
                id:natureGrid
                width:parent.width
                height:parent.height
                start: 189;
                end: 304;
            }

            EmojiGrid{
                id:placesGrid
                width:parent.width
                height:parent.height
                start: 305;
                end: 534;
            }

            EmojiGrid{
                id:objectsGrid
                width:parent.width
                height:parent.height
                start: 535;
                end: 636;
            }

            EmojiGrid{
                id:symbolsGrid
                width:parent.width
                height:parent.height
                start: 637;
                end: 845
            }
	  }
	}

    function selectEmoji(emojiCode, hide){

        //console.log("GOT "+emojiCode)
        //emojiSelected(emojiCode);

        /*if(EmojiHelper.emojiSelectCallback){
            EmojiHelper.emojiSelectCallback(emojiCode);
        }*/


        var textarea = EmojiHelper.emojiTextarea;
	var emojiImg = '<img src="'+emojiRelativePath+'/24/'+emojiCode+'.png" />'
	textarea.insert(emojiImg)

	addRecentEmoji(emojiCode);

       // console.log(textarea.text)
	if (hide || !longDialog)
	{
	    textarea.forceActiveFocus();
	    emojiSelector.accept();
	    hideAll();
	}
	else
	{
	    feedbackEffect.play();
	}
    }

}
