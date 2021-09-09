# frozen_string_literal: true

class MessagesController < ApplicationController
  before_action :authenticate!

  def index; end

  def show
    correspondent = Account.find(params[:account_id])
    messages = Message.where(recipient: current_account, sender: correspondent)
                      .or(Message.where(recipient: correspondent, sender: current_account))
                      .order(created_at: :asc)

    render json: { correspondent: AccountBlueprint.render_as_json(correspondent),
                   messages: MessageBlueprint.render_as_json(messages) }
  end

  def create
    current_account.sent_messages.create(create_message_params)
    render json: {}
  end

  private

  def create_message_params
    params.permit(:recipient_id, :body)
  end
end
