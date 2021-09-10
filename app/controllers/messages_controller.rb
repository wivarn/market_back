# frozen_string_literal: true

class MessagesController < ApplicationController
  before_action :authenticate!

  def index
    render json: MessageBlueprint.render(Message.latest_for(current_account.id).includes(:sender, :recipient),
                                         view: :with_correspondents)
  end

  def show
    correspondent = Account.find(params[:account_id])
    messages = Message.where(recipient: current_account, sender: correspondent)
                      .or(Message.where(recipient: correspondent, sender: current_account))
                      .order(created_at: :asc)

    render json: { correspondent: AccountBlueprint.render_as_json(correspondent),
                   messages: MessageBlueprint.render_as_json(messages) }
  end

  def create
    message = current_account.sent_messages.new(create_message_params)
    if message.save
      render json: MessageBlueprint.render(message)
    else
      render json: message.errors, status: :unprocessable_entity
    end
  end

  private

  def create_message_params
    params.permit(:recipient_id, :body)
  end
end
