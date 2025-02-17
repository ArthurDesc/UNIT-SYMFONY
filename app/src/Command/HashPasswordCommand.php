<?php

namespace App\Command;

use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface;
use App\Entity\User;

#[AsCommand(
    name: 'app:hash-password',
    description: 'Hashes a password for testing.'
)]
class HashPasswordCommand extends Command
{
    public function __construct(
        private UserPasswordHasherInterface $passwordHasher
    ) {
        parent::__construct();
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        $user = new User();
        
        $hashedPasswordAdmin = $this->passwordHasher->hashPassword($user, 'admin');
        $hashedPasswordUser = $this->passwordHasher->hashPassword($user, 'user');

        $output->writeln('Admin password hash: ' . $hashedPasswordAdmin);
        $output->writeln('User password hash: ' . $hashedPasswordUser);

        return Command::SUCCESS;
    }
} 