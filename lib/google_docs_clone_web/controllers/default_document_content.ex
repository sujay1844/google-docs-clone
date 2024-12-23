defmodule GoogleDocsCloneWeb.DefaultDocumentContent do
  @moduledoc """
  Default document content for the application.
  """

  def content do
    ~S"""
    # Welcome to Google Docs Clone
    This is a sample document created by the Google Docs Clone application.

    # Heading 1

    ## Heading 2

    ### Heading 3

    #### Heading 4

    ##### Heading 5

    ###### Heading 6

    # Formatting

    `code`

    <!--Comments -->

    **bold**
    __bold__


    *italics*
    _italics_

    ~~Strikethourgh~~

    # Horizontal Rule

    ---

    # Escape Sequences

    For code enclosed by single backtick(\`) , use double backticks(\`\`)
    For code enclosed by double backtick(\`\`) , use triple backticks(\`\`\`)
    And so on

    > Block Quotes

    # [Links](https://www.example.com)

    [Link with a title](https://www.example.com "Title")

    [Local references](name-of-local-file)

    # Unordered Lists

    * Item 1
    * Item 2
    * Item 3
    * and so on
      * Nested Item 1
      * Nested Item 2
      * and so on
        * Nested Nested Item 1
        * Nested Nested Item 2
        * and so on

    # Ordered Lists

    1. Item 1
    1. Item 2
    1. and so on
      1. Nested Item 1
      1. Nested Item 2
      1. and so on

    # Code Blocks

    ```
    A block of code
    Line 1
    Line 2
    and so on
    ```

    ```bash
    cd ~
    ls -al
    echo Hello World
    ```

    ```python
    def add(num1, num2):
    return num1 + num2
    print("Hello World")
    ```

    ```java
    public static void main(String args[])
    {
    System.out.println("Hello World")
    }
    ```
    # Images

    ![Images](https://markdown-here.com/img/icon256.png)

    # Emojis

    :fu: 

    :kiss: :peach: :wave: 

    :lips: :eggplant:

    :fist: :banana:

    :point_right: :peanuts:

    :weary: :rocket: :fist: :sweat_drops:

    :monkey: :clap:

    Ok that's enough for now.

    Find the whole list of supported emojis [here](https://gist.github.com/rxaviers/7360908)

    # Tables

    | Name    | ID No. |
    | ------- | ------ |
    | John    | 1234   |
    | William | 987    |
    | Jessie  | 6813   |

    # To-do lists

    * [x] Completed Task 1
    * [x] Completed Task 2
    * [ ] Incomplete Task 1
    * [ ] Incomplete Task 2

    # Collapsed text
    <details>
    <summary>Collapsed Item Title</summary>
    <p>Collapsed content</p>
    <p>Other collapsed content.</p>
    </details>

    # Keystrokes
    <kbd>Ctrl+K</kbd>

    """
  end
end
