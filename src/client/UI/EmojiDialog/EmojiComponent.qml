import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0
import "../common/js/Global.js" as Helpers
import "../common/js/settings.js" as MySettings;
import QtMobility.feedback 1.1
import "Components"
import "../common"

Item {
	id: emojiSelector
	visible: false


    property string titleText: qsTr("Select Emoji")
    property string emojiPath:"../common/images/emoji/";
    property string emojiRelativePath; //relative to textfield
    
    property variant emojiTextArea
    property bool inverted: true
    
    signal selected()
    
    ThemeEffect {
      id: feedbackEffect
      effect: "BasicButton"
    }

    function get32(code){
        var c = ""+code;
        return emojiPath+"32/"+c+".png";
    }
    
    function accept() {
	emojiSelector.visible = false
    }

    function open(textarea, relativePath){
        if(!textarea){
            consoleDebug("NO TEXTAREA SPECIFIED FOR EMOJI, NOT OPENING!")
            return;
        }
        textarea.lastPosition = textarea.cursorPosition
        emojiSelector.emojiTextArea = textarea

        emojiRelativePath = relativePath?relativePath:"/opt/waxmppplugin/bin/wazapp/UI/common/images/emoji"
	emojiSelector.visible = true
        
        emojiList.loadEmoji()
    }

ButtonRow {
    id: emojiCategory
    checkedButton: peopleEmoji
    anchors.horizontalCenter: parent.horizontalCenter
    width: parent.width

    EmojiTabButton {
	id: recentEmoji
	iconSource: get32("E02C");
	inverted: emojiSelector.inverted
	onClicked: {
	    emojiList.offset = 0.0
            emojiList.loadEmoji()
	}
    }

    EmojiTabButton {
	id: peopleEmoji
	iconSource: get32("E057");
	inverted: emojiSelector.inverted
	onClicked: {
	    emojiList.offset = 5.0
	    emojiList.loadEmoji()
	}
    }

    EmojiTabButton {
	id: natureEmoji
	iconSource: get32("E303");
	inverted: emojiSelector.inverted
	onClicked: {
	    emojiList.offset = 4.0
	    emojiList.loadEmoji()
	}
    }

    EmojiTabButton {
	id: placesEmoji
	iconSource: get32("E325")
	inverted: emojiSelector.inverted
	onClicked: {
	    emojiList.offset = 3.0
	    emojiList.loadEmoji()
	}
    }

    EmojiTabButton {
	id: objectsEmoji
	iconSource: get32("E036")
	inverted: emojiSelector.inverted
	onClicked: {
	    emojiList.offset = 2.0
	    emojiList.loadEmoji()
	}
    }

    EmojiTabButton {
	id: symbolsEmoji
	iconSource: get32("E210")
	inverted: emojiSelector.inverted
	onClicked: {
	    emojiList.offset = 1.0
	    emojiList.loadEmoji()
	}
    }
}

Rectangle {
    id:emojiContainer
    width: parent.width
    height: emojiSelector.height-emojiCategory.height
    anchors.top:emojiCategory.bottom
    anchors.topMargin: 5
    color: inverted?"black":"white"
    
    PathView {
	property bool emojiload: false
	
	id: emojiList	
	anchors.fill: emojiContainer
	preferredHighlightBegin: 1/6
	preferredHighlightEnd: 2/6
	offset: 0.0
	model: ListModel {
	    ListElement { emjstart:0; emjend:0; recent: true; col: "red" }
	    ListElement { emjstart:0; emjend:188; recent: false; col: "green" }
	    ListElement { emjstart:189; emjend:304; recent: false; col: "blue" }
	    ListElement { emjstart:305; emjend:534; recent: false; col: "cyan" }
	    ListElement { emjstart:535; emjend:636; recent: false; col: "magneta" }
	    ListElement { emjstart:637; emjend:845; recent: false; col: "yellow" }
	}
	delegate: EmojiView {
	    id: myDelegate
	    height: emojiList.height
	    width: emojiList.width
	    
	    start: emjstart
	    end: emjend
	    showRecent: recent
	    
	    inverted: emojiSelector.inverted
	    
	    onSelected: selectEmoji(code)
	}
	
	path: Path {
	    startX: -(emojiList.width/2)
	    startY: emojiList.height/2
	    PathLine{
		x: (emojiList.model.count*emojiList.width) - (emojiList.width/2)
		y: emojiList.height/2
	    }
	}
	
	onMovementEnded: loadEmoji()
	
	function loadEmoji() {
	    console.log("loadEmoji index: " + currentIndex)
	    console.log("loadEmoji offset: " + emojiList.offset)
	    
	    switch (emojiList.offset) {
		    case 0: recentEmoji.checked = true; break
		    case 5: peopleEmoji.checked = true; break
		    case 4: natureEmoji.checked = true; break
		    case 3: placesEmoji.checked = true; break
		    case 2: objectsEmoji.checked = true; break
		    case 1: symbolsEmoji.checked = true; break
		}
		
	    emojiList.childAt(100, emojiList.height - 20).load()
	}
	
	MouseArea { anchors.fill: parent }
    }
    }


    function selectEmoji(emojiCode){

	var emojiImg = '<img src="'+emojiRelativePath+'/24/'+emojiCode+'.png" />'
	emojiSelector.emojiTextArea.insert(emojiImg)

	addRecentEmoji(emojiCode);

	feedbackEffect.play();
	
	selected()
    }

}
