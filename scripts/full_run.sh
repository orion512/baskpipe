# python -c "from dometl import run_dometl; run_dometl()" -t init -cp dometl_config
# python -c "from dometl import run_dometl; run_dometl()" -t stage -ep datasets\\game_data\\seasons -tb st_game -cp dometl_config
# python -c "from dometl import run_dometl; run_dometl()" -t stage -ep datasets\\url_data\\playoff_urls -tb st_playoff_url -cp dometl_config
# python -c "from dometl import run_dometl; run_dometl()" -t live -tb game -cp dometl_config
# python -c "from dometl import run_dometl; run_dometl()" -t test -tb game -cp dometl_config

dometl -t init -cp dometl_config
dometl -t stage -ep datasets\\game_data\\seasons -tb st_game -cp dometl_config
dometl -t stage -ep datasets\\url_data\\playoff_urls -tb st_playoff_url -cp dometl_config
dometl -t live -tb game -cp dometl_config
dometl -t test -tb game -cp dometl_config