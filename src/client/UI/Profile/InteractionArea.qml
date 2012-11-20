import QtQuick 1.1
import com.nokia.meego 1.0

Item{
    id: root	

    width: parent.width 
    height: parent.height 

    property double finalScale: Math.round(image.scale*1000)/1000

    property color pressedColor: "#7727a01b"
    property alias source: image.source
    
    property int rectX: Math.round(bucketContainer.x)
    property int rectY: Math.round(bucketContainer.y)
    property int rectW: bucketContainer.width
    property int rectH: bucketContainer.height
    property int angle: rotation.angle
    
    property int bucketMaxSize
    property int bucketMinSize
    
    onHeightChanged: image.fitToScreen()
    
    function rotate() {
	rotation.angle = rotation.angle + 90
	if (rotation.angle == 360)
	    rotation.angle = 0
    }

    Flickable{
        id: flickable
	
        anchors.fill: parent
        contentHeight: imageContainer.height
        contentWidth: imageContainer.width
        interactive: !bucketMouseArea.pressed && !bucketResizeMouseArea.pressed

        Item{
            id: imageContainer
            width: Math.max(image.width * image.scale, flickable.width)
            height: Math.max(image.height * image.scale, flickable.height)

 	     Loader{
        	  anchors.centerIn: parent
        	  sourceComponent: {
            		switch(image.status){
            			case Image.Loading:
                			return loadingIndicator
            			case Image.Error:
                			return failedLoading
            			default:
                			return undefined
			}
            	  }
            }

            Component{
            	   id: loadingIndicator

            	   BusyIndicator{
                     id: busyIndicator
                     running: image.status == Image.Ready ? false : true 
			visible: running
                     platformStyle: BusyIndicatorStyle{ size: "large" }
                 }
            }

	     Component{ id: failedLoading; Label{ text: qsTr("Error loading image") } }

            Image{
                id: image

		    function fitToScreen(){
                    scale = Math.min(flickable.width / width, flickable.height / height, 1)
                    pinchArea.minScale = scale
                    previousScale = scale
                }

                property real previousScale
                
                transform: Rotation {id: rotation; origin.x: Math.round(image.sourceSize.width / 2); origin.y: Math.round(image.sourceSize.height / 2); angle: 0 }
                smooth: true

                asynchronous: true
                anchors.centerIn: parent
                fillMode: Image.PreserveAspectFit
   
                onStatusChanged: {
                    if(status === Image.Ready) {
			     console.log("image loaded")
			     image.fitToScreen()
			     bucketContainer.height = Math.min(image.sourceSize.width, image.sourceSize.height)
			     bucketContainer.width = Math.min(image.sourceSize.width, image.sourceSize.height)
			     bucketContainer.x = 0
			     bucketContainer.y = 0
			     flickable.returnToBounds()
                    }
                }

                onScaleChanged: {
                    var scaled = scale / previousScale
                    if ((width * scale) > flickable.width) {
                        var xoff = (flickable.width / 2 + flickable.contentX) * scaled;
                        flickable.contentX = xoff - flickable.width / 2
                    }
                    if ((height * scale) > flickable.height) {
                        var yoff = (flickable.height / 2 + flickable.contentY) * scaled;
                        flickable.contentY = yoff - flickable.height / 2
                    }
                    previousScale = scale
                }
         
        PinchArea{
            id: pinchArea

            property real minScale: 1.0
            property real maxScale: 2.0

            anchors.fill: parent
            pinch.target: image
            pinch.minimumScale: minScale * 0.5
            pinch.maximumScale: maxScale * 1.5

            onPinchFinished: {
                flickable.returnToBounds()
                if(image.scale < pinchArea.minScale){
                    bounceBackAnimation.to = pinchArea.minScale
                    bounceBackAnimation.start()
                }
                else if(image.scale > pinchArea.maxScale){
                    bounceBackAnimation.to = pinchArea.maxScale
                    bounceBackAnimation.start()
                }
            }

            NumberAnimation{
                id: bounceBackAnimation
                target: image
                duration: 250
                property: "scale"
                from: image.scale
            }
        }
        
        Item{
            id: bucketContainer

     	    height: Math.min(image.sourceSize.width, image.sourceSize.height)
            width: Math.min(image.sourceSize.width, image.sourceSize.height)

            Rectangle{
                id: bucketBorder
                anchors.fill: parent
                border.width: 4 / image.scale
                border.color: (bucketMouseArea.pressed || bucketResizeMouseArea.pressed) ? "red" : "lightgray"
                color: "transparent"
            }

            MouseArea{
                id: bucketMouseArea
                anchors.fill: parent
                drag.target: bucketContainer
                drag.minimumX: 0
                drag.minimumY: 0
                drag.maximumX: image.width - bucketBorder.width - 4 
                drag.maximumY: image.height - bucketBorder.height - 4
            }
            
            Image{
		id: resizeIndicator
		anchors{ right: parent.right; bottom: parent.bottom }
		source: "/opt/waxmppplugin/bin/wazapp/UI/common/images/imageInteractor.png"
		height: sourceSize.height / image.scale
		width: sourceSize.width / image.scale
            }
            
            MouseArea{
		id: bucketResizeMouseArea

		property int oldMouseX
		property int oldMouseY
		  
		anchors.fill: resizeIndicator

        	onPressed: {
			oldMouseX = mouseX
			oldMouseY = mouseY
		}

		onPositionChanged: {
			if (pressed) {
				var delta = Math.round(Math.min((mouseX - oldMouseX),(mouseY - oldMouseY)))
				var newSize = bucketContainer.width+delta
				var maxSize = Math.min(image.sourceSize.height, image.sourceSize.width)
				console.log("delta: " + delta)
				console.log("newSize: " + newSize)
				console.log("maxSize: " + maxSize)
				console.log("bucketContainer.y: " + bucketContainer.y)
				console.log("bucketContainer.x: " + bucketContainer.x)
				if (
				  (bucketContainer.height + delta <= maxSize) && 
				  (bucketContainer.width + delta <= maxSize) && 
				  (newSize >= bucketMinSize)
				  && (bucketContainer.y + rectH + delta <= image.sourceSize.height)
				  && (bucketContainer.x + rectW + delta <= image.sourceSize.width)
				) {
					bucketContainer.height = newSize
					bucketContainer.width = newSize
				}
			}
                }
	    }
        }
    }
		}
	}
	ScrollDecorator{ flickableItem: flickable }
}

