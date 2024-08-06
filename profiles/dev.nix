{ config, lib, pkgs, ... }:

let
  my-python-packages = python-packages: with python-packages; [
    rich
    ipython
    pip
    virtualenv
    black
    requests
    numpy
    pandas
    matplotlib
    jupyter
  ];
  my-python = pkgs.python3.withPackages my-python-packages;
in
{
    environment.systemPackages = with pkgs; [
        # Languages
        go

        # Tools
        sqlitebrowser

        # Python packages
        my-python
    ];
}