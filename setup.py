from setuptools import setup, find_packages

setup(
    name="wordlist-generator",
    version="1.0",
    description="A Wordlist Generator Tool for Cybersecurity",
    author="Your Name",
    author_email="your.email@example.com",
    packages=find_packages(),
    entry_points={
        "console_scripts": [
            "wordlist-generator=wordlist_generator:main",
        ],
    },
    install_requires=[],
    classifiers=[
        "Programming Language :: Python :: 3",
        "Operating System :: OS Independent",
    ],
    python_requires='>=3.6',
)
