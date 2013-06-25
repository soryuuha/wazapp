/***************************************************************************
**
** Copyright (c) 2012, Tarek Galal <tarek@wazapp.im>
**
** This file is part of Wazapp, an IM application for Meego Harmattan
** platform that allows communication with Whatsapp users.
**
** Wazapp is free software: you can redistribute it and/or modify it under
** the terms of the GNU General Public License as published by the
** Free Software Foundation, either version 2 of the License, or
** (at your option) any later version.
**
** Wazapp is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
** See the GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with Wazapp. If not, see http://www.gnu.org/licenses/.
**
****************************************************************************/

function getChatData() {
   // addMessage("Hello there!",true,"10:00am");
   // addMessage("Hey!!",false,"10:00am");
}

//function addMessage(id,message,type,formattedDate,timestamp,status)
function addMessage(reverse,position,message)
{
    //var reverseAppend = reverse;

    //console.log("Adding message");
    var msg_status = message.status == 0?"sending":message.status==1?"pending":"delivered";

    //console.log("assign author");
    var author = message.contact;

    var targetIndex = position //conv_data.count;
	//if (reverse) targetIndex = conv_data.count-1
	if (targetIndex > conv_data.count) targetIndex = conv_data.count

    //console.log("Looking where to insert ");



   /* if(lastMessage && message.msg_id < lastMessage.msg_id){
            //Message is loaded from a "load more" request
            //Now look where to put it
            targetIndex = 0;
            reverseAppend = true;

            for(var i=0; i <conv_data.count-1;i++){
                var item = conv_data.get(i);

                if(item.msg_id > message.msg_id)
                {
                    targetIndex = i==0?0:i;
                    break;
                }
            }
    }*/

    //console.log("inserting message at "+targetIndex +" - pushName: " +message.pushname);
    conv_data.insert(targetIndex, {"msg_id":message.id,
                            "content":message.content,
                            "type":message.type,
                            "timestamp":message.formattedDate,
                            "formattedDate":message.formattedDate,
                            "created":message.created,
                            "status":msg_status,
                            "author":author,
                            "pushname":message.pushname,
                            "mediatype_id":message.media_id?(typeof(message.media)!="undefined"?message.media.mediatype_id:1):1,
                            "media":message.media,
                            "progress":0})

    updateLastMessage();

    //conv_data.append({"msg_id":id,"message":message,"type":type, "timestamp":timestamp,"status":msg_status});
    if (!reverse) {
		consoleDebug("MOVING TO BOTTOM OF LIST")
		conv_items.positionViewAtEnd()
	}

   // else conv_items.positionViewAtIndex(targetIndex);
    // conversation_view.conversationUpdated(id,type,conversation_view.user_id,message,timestamp,formattedDate);
   // if (!loadConvsReverse) conversation_view.conversationUpdated(message);
}

function onTyping(user_id){
    status.text="Typing...";
}

function onPaused(user_id){
    status.text="";
}
