#!/usr/bin/zsh

export ZSH=~/.oh-my-zsh
source $ZSH/plugins/z/z.plugin.zsh

editor=code

log_file=~/.local/share/pop-launcher/plugins/open/log.txt
save_file=~/.local/share/pop-launcher/plugins/open/save.txt


read input

if [[ $input == '{"Interrupt"'* ]]; then
    exit 0
fi

if [[ $input == '{"Activate"'* ]]; then
    choice=$(echo "$input" | cut -d':' -f2 | cut -d'}' -f1)
    cmd=$(sed -n ${choice}p $save_file)
    echo '"Close"'
    eval $cmd
fi

if [[ $input == '{"Search"'* ]]; then
    term=$(echo "$input" | cut -d'"' -f4 | cut -d'"' -f1)
    term=${term#>}
    
    if [[ -z "$term" ]]; then
        exit 0
    fi

    items=$(zshz -l -t $term | awk '{print $NF}' | tac)

    id=1
    echo > $save_file
    while IFS= read -r item; do
        sed -i "${id}i${editor} ${item}" "${save_file}"
        item_lower=$(echo $item | tr '[:upper:]' '[:lower:]')
        echo "{\"Append\":{\"id\":$id,\"name\":\"$item_lower\",\"description\":\"\"}}"

        if [[ $id -lt 6 ]]; then
            ((id++))
        else
            exit 0
        fi
    done <<< $items

    echo '"Finished"'
fi
