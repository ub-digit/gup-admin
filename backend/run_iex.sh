#!/bin/bash
 export $(grep '^[[:blank:]]*[^[:blank:]#;]' ../docker/.env | cat) && iex -S mix phx.server