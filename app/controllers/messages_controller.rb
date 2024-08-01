# app/controllers/messages_controller.rb
class MessagesController < ApplicationController
    before_action :find_conversation
  
    def index
      @messages = @conversation.messages
      @message = @conversation.messages.new
    end
  
    def create
      @message = @conversation.messages.new(message_params)
      @message.user = current_user
  
      if @message.save
        redirect_to conversation_messages_path(@conversation)
      end
    end
  
    private
    def find_conversation
      @conversation = Conversation.find(params[:conversation_id])
    end
  
    def message_params
      params.require(:message).permit(:content)
    end
  end