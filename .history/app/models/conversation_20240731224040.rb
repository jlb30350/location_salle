# app/models/conversation.rb
class Conversation < ApplicationRecord
    belongs_to :sender, class_name: 'User'
    belongs_to :recipient, class_name: 'User'
    has_many :messages, dependent: :destroy
  
    validates :sender_id, uniqueness: { scope: :recipient_id }
  
    scope :between, -> (sender_id, recipient_id) do
      where("(conversations.sender_id = ? AND conversations.recipient_id = ?) OR (conversations.sender_id = ? AND conversations.recipient_id = ?)", sender_id, recipient_id, recipient_id, sender_id)
    end
  end
  
  # app/models/message.rb
  class Message < ApplicationRecord
    belongs_to :conversation
    belongs_to :user
  
    validates_presence_of :content, :conversation_id, :user_id
  
    def message_time
      created_at.strftime("%d/%m/%y at %l:%M %p")
    end
  end
  
  # app/controllers/conversations_controller.rb
  class ConversationsController < ApplicationController
    before_action :authenticate_user!
  
    def index
      @users = User.all
      @conversations = Conversation.where("sender_id = ? OR recipient_id = ?", current_user.id, current_user.id)
    end
  
    def create
      if Conversation.between(params[:sender_id], params[:recipient_id]).present?
        @conversation = Conversation.between(params[:sender_id], params[:recipient_id]).first
      else
        @conversation = Conversation.create!(conversation_params)
      end
      redirect_to conversation_messages_path(@conversation)
    end
  
    private
    def conversation_params
      params.permit(:sender_id, :recipient_id)
    end
  end
  
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