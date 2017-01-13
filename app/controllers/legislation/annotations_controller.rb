class Legislation::AnnotationsController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :authenticate_user!, only: [:create]

  load_and_authorize_resource :process
  load_and_authorize_resource :draft_version, through: :process
  load_and_authorize_resource

  has_orders %w{most_voted newest oldest}, only: :show

  def index
    @annotations = @draft_version.annotations
  end

  def show
    @commentable = @annotation
    @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)
    set_comment_flags(@comment_tree.comments)
  end

  def create
    if !@process.open_phase?(:allegations) || @draft_version.final_version?
      render json: {}, status: :not_found and return
    end

    @annotation = @draft_version.annotations.new(annotation_params)
    @annotation.author = current_user
    if @annotation.save
      track_event
      render json: @annotation.to_json
    else
      render json: {}, status: :unprocessable_entity
    end
  end

  def search
    @annotations = @draft_version.annotations
    annotations_hash = { total: @annotations.size, rows: @annotations }
    render json: annotations_hash.to_json
  end

  def comments
    @annotation = Legislation::Annotation.find(params[:annotation_id])
  end

  private

    def annotation_params
      params
        .require(:annotation)
        .permit(:quote, :text, ranges: [:start, :startOffset, :end, :endOffset])
    end

    def track_event
      ahoy.track "legislation_annotation_created".to_sym,
                 "legislation_annotation_id": @annotation.id,
                 "legislation_draft_version_id": @draft_version.id
    end

end
