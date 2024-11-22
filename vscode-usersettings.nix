{
  zenMode = {
    showTabs = "single";
    hideLineNumbers = false;
    hideStatusBar = false;
  };

  explorer.confirmDelete = false;

  files.associations = {
    "*.tera"= "html";
  };

  terminal.integrated.defaultProfile.linux = "zsh";

  editor.lineNumbers = "relative";

  vim.leader = "<space>";
  vim.easymotion = true;
  vim.normalModeKeyBindingsNonRecursive = [
    {
      "before"= ["<leader>" "<space>"];
      "after"= [];
      "commands"= [
        {
          "command"= "workbench.action.showCommands";
          "args"= [];
        }
      ];
    }

    { 
      "before"= ["<leader>" "p"];
      "after"= [];
      "commands"= [
        {
          "command"= "workbench.action.quickOpen";
          "args"= [];
        }
      ]; 
    }
    
    {
      "before"= ["<leader>" "h"];
      "after"= [];
      "commands"= [
        {
          "command"= "editor.action.showHover";
          "args"= [];
        }
      ]; 
    }

    {
      "before"= ["g" "h"];
      "after"= [];
      "commands"= [
        {
          "command"= "references-view.showCallHierarchy";
          "args"= [];
        }
      ]; 
    }

    {
      "before"= ["g" "r"];
      "after"= [];
      "commands"= [
        {
          "command"= "editor.action.goToReferences";
          "args"= [];
        }
      ]; 
    }

    {
      "before"= ["g" "R"];
      "after"= [];
      "commands"= [
        {
          "command"= "references-view.findReferences";
          "args"= [];
        }
      ]; 
    }

    {
      "before"= ["<leader>" "w" "o"];
      "after"= [];
      "commands"= [
        {
          "command"= "runCommands";
          "args"= {
            commands = [
            "workbench.action.closeSidebar"
            "workbench.action.closeEditorsInOtherGroups"
            "workbench.action.closePanel"
            ];
          };
        }
      ]; 
    }

    {
      "before" = ["<leader>" "w" "z"];
      "commands" = [
        {"command" = "workbench.action.toggleZenMode";}
      ];
    }

    # remap search for easymotion
    { 
      "before"= ["<leader>" "f"];
      "after"= ["<leader>" "<leader>" "s"];
    }
  ]; 
}
