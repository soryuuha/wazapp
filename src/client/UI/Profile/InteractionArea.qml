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
	
	image.fitToScreen()
	flickable.returnToBounds()
    }

    Flickable{
        id: flickable
	
        anchors.fill: parent
        contentHeight: imageContainer.height
        contentWidth: imageContainer.width
        interactive: !bucketMouseArea.pressed && !bucketResizeMouseArea.pressed
        clip: true

        Item{
            id: imageContainer
            width: Math.max(image.getWidth() * image.scale, flickable.width)
            height: Math.max(image.getHeight() * image.scale, flickable.height)

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

                function getHeight(){
		    switch (rotation.angle)
		    {
			case 0:
			case 180:	return image.height
			case 90:
			case 270:	return image.width
		    }
                }
                
                function getWidth(){
		    switch (rotation.angle)
		    {
			case 0:
			case 180:	return image.width
			case 90:
			case 270:	return image.height
		    }
                }
                
                function fitToScreen(){
                    scale = Math.min(flickable.width / getWidth(), flickable.height / getHeight(), 1)
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
            transform: Rotation { origin.x: Math.round(bucketContainer.width/2); origin.y:  Math.round(bucketContainer.height/2); angle: 0 - rotation.angle}

            Rectangle{
                id: bucketBorder
                anchors.fill: parent
                border.width: 4 / image.scale
                border.color: (bucketMouseArea.pressed || bucketResizeMouseArea.pressed) ? pressedColor : "lightgray"
                color: "transparent"
                visible: image.status == Image.Ready
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
		visible: image.status == Image.Ready
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
				var deltaX = 0
				var deltaY = 0
				switch (rotation.angle)
				{
				  case 90:	deltaY=-delta
						break
				  case 180:	deltaX=-delta
						deltaY=-delta
						break
				  case 270:	deltaX=-delta
						break
				}
				if (
				  (bucketContainer.height + bucketContainer.x + delta <= image.sourceSize.width) && 
				  (bucketContainer.width + bucketContainer.y + delta <= image.sourceSize.height) && 
				  (bucketContainer.width + delta >= bucketMinSize) &&
				  (bucketContainer.height + delta >= resizeIndicator.height) &&
				  (bucketContainer.x + deltaX >= 0) &&
				  (bucketContainer.y + deltaY >= 0)
				) {
					bucketContainer.height += delta
					bucketContainer.width += delta
					bucketContainer.x += deltaX
					bucketContainer.y += deltaY
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

