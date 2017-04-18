defmodule Evolution.ErrorHelpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """

  use Phoenix.HTML

  @doc """
  Generates tag for inlined form input errors.
  """
  def error_tag(form, field) do
    error = form.errors[field]
    if error do
      content_tag :span, translate_error(error), class: "help-block"
    end
  end

  def error_json({field, msg}) do
    {field, translate_error(msg)}
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # Because error messages were defined within Ecto, we must
    # call the Gettext module passing our Gettext backend. We
    # also use the "errors" domain as translations are placed
    # in the errors.po file. On your own code and templates,
    # this could be written simply as:
    #
    #     dngettext "errors", "1 file", "%{count} files", count

    if Keyword.has_key?(opts, :count) do
      Gettext.dngettext(Evolution.Gettext, "errors", msg, msg, opts[:count], opts)
    else
      translate_error(msg)
    end
  end

  def translate_error(msg) do
    Gettext.dgettext(Evolution.Gettext, "errors", msg)
  end
end
