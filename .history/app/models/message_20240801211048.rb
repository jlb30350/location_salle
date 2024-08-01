# app/models/message.rb
class Message < ApplicationRecord
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, class_name: 'User'
  validates :content, presence: true
end

# app/controllers/messages_controller.rb
class MessagesController < ApplicationController
  def index
    @received_messages = current_user.received_messages
    @sent_messages = current_user.sent_messages
  end

  def new
    @message = Message.new
    @recipient = User.find(params[:recipient_id])
  end

  def create
    @message = current_user.sent_messages.build(message_params)
    if @message.save
      redirect_to messages_path, notice: 'Message envoyé avec succès.'
    else
      render :new
    end
  end

  private

  def message_params
    params.require(:message).permit(:content, :recipient_id)
  end
end