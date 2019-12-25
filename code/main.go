package main

import (
	"fmt"
	"io"
	"io/ioutil"
	"os"

	"golang.org/x/crypto/ssh"
)

func publicKeyFile(file string) ssh.AuthMethod {
	buffer, err := ioutil.ReadFile(file)
	if err != nil {
		return nil
	}

	key, err := ssh.ParsePrivateKey(buffer)
	if err != nil {
		return nil
	}
	return ssh.PublicKeys(key)
}

func runCommand(cmd string, conn *ssh.Client) {
	sess, err := conn.NewSession()
	if err != nil {
		panic(err)
	}
	defer sess.Close()
	sessStdOut, err := sess.StdoutPipe()
	if err != nil {
		panic(err)
	}
	go io.Copy(os.Stdout, sessStdOut)
	sessStderr, err := sess.StderrPipe()
	if err != nil {
		panic(err)
	}
	go io.Copy(os.Stderr, sessStderr)
	err = sess.Run(cmd) // eg., /usr/bin/whoami
	if err != nil {
		panic(err)
	}
}

func main() {
	// Use public key authentication method
	sshConfig := &ssh.ClientConfig{
		User: "tree3",
		Auth: []ssh.AuthMethod{
			publicKeyFile("/Users/barry/Projects/tree3/deployments/services/sshd/root/home/tree3/.ssh/id_rsa"),
		},
		HostKeyCallback: ssh.InsecureIgnoreHostKey(),
	}

	// Establishing new SSH connection
	connection, err := ssh.Dial("tcp", "host:port", sshConfig)
	if err != nil {
		fmt.Printf("Failed to dial: %s", err)
		return
	}

	// Creating a new session
	session, err := connection.NewSession()
	if err != nil {
		fmt.Printf("Failed to create session: %s", err)
		return
	}

	// Create an xterm terminal
	modes := ssh.TerminalModes{
		ssh.ECHO:          0,     // disable echoing
		ssh.TTY_OP_ISPEED: 14400, // input speed = 14.4kbaud
		ssh.TTY_OP_OSPEED: 14400, // output speed = 14.4kbaud
	}
	if err := session.RequestPty("xterm", 80, 40, modes); err != nil {
		session.Close()
		fmt.Printf("request for pseudo terminal failed: %s", err)
		return
	}

	// Attach stdin/out/err
	stdin, err := session.StdinPipe()
	if err != nil {
		fmt.Printf("Unable to setup stdin for session: %v", err)
		return
	}
	go io.Copy(stdin, os.Stdin)

	stdout, err := session.StdoutPipe()
	if err != nil {
		fmt.Printf("Unable to setup stdout for session: %v", err)
		return
	}
	go io.Copy(os.Stdout, stdout)

	stderr, err := session.StderrPipe()
	if err != nil {
		fmt.Printf("Unable to setup stderr for session: %v", err)
		return
	}
	go io.Copy(os.Stderr, stderr)

	// Command execution
	err = session.Run("ls -al /home/tree3")
}
