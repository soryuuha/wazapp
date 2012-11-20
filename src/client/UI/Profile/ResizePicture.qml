import QtQuick 1.1
import com.nokia.meego 1.0
import "../common/js/settings.js" as MySettings
import "../common/js/Global.js" as Helpers
import "../common"

WAPage {
    id: container
    
    Binding { target: container; property: "width"; value: mainPage.parent.width }
    Binding { target: container; property: "height"; value: mainPage.parent.height }
    Binding { target: container; property: "orientationLock"; value: mainPage.orientationLock}
    
    property string picture
    property int maximumSize
    property int minimumSize
    
    property string filename
    
    signal selected()

    tools: ToolBarLayout {
        id: toolBar
        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: {
		pageStack.pop();
	    }
        }
        
        ToolIcon {
            platformIconId: "toolbar-refresh4"
            onClicked: {
		pinch.rotate()
	    }
        }
        
	ToolIcon {
            id: doneButton
            platformIconId: "toolbar-done"
	    onClicked: {
	      transformPicture(picture, WAConstants.CACHE_PATH+"/"+filename, pinch.rectX, pinch.rectY, pinch.rectW, maximumSize, pinch.angle)
	      selected()
	    }
	}
    }

    InteractionArea {
	id: pinch
	anchors.top: parent.top
	anchors.topMargin: 73
	height: parent.height -73
	width: parent.width
	source: picture
	bucketMaxSize: maximumSize
	bucketMinSize: minimumSize
    }
    
    WAHeader{
	title: qsTr("Change picture")
	anchors.top:parent.top
	width:parent.width
	height: 73
    }
}
